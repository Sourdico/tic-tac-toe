import 'package:flutter/material.dart';

void main() {
  runApp(const InfiniteTicTacToeApp());
}

class InfiniteTicTacToeApp extends StatelessWidget {
  const InfiniteTicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game board
  List<Cell> board = List.generate(9, (index) => Cell(index: index));

  // Player turns
  bool isXTurn = true;

  // Player move tracking
  List<int> xPositions = [];
  List<int> oPositions = [];

  // Game state
  int moveCount = 0;
  String? winner;

  // Winning combinations
  final List<List<int>> winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6] // Diagonals
  ];

  void makeMove(int index) {
    if (winner != null || board[index].symbol != null) {
      return;
    }

    setState(() {
      String currentSymbol = isXTurn ? 'X' : 'O';
      List<int> currentPlayerPositions = isXTurn ? xPositions : oPositions;

      // Place the symbol on the board
      board[index].symbol = currentSymbol;

      // Add this position to the player's positions list
      currentPlayerPositions.add(index);

      // If the player now has more than 3 symbols, remove the oldest one
      if (currentPlayerPositions.length > 3) {
        int oldestPosition = currentPlayerPositions.removeAt(0);
        board[oldestPosition].symbol = null;
      }

      // Update the tracking lists
      if (isXTurn) {
        xPositions = currentPlayerPositions;
      } else {
        oPositions = currentPlayerPositions;
      }

      // Check for winner
      checkWinner();

      // Increment move count
      moveCount++;

      // Switch turns
      isXTurn = !isXTurn;
    });
  }

  void checkWinner() {
    for (var combo in winningCombinations) {
      if (board[combo[0]].symbol != null &&
          board[combo[0]].symbol == board[combo[1]].symbol &&
          board[combo[0]].symbol == board[combo[2]].symbol) {
        winner = board[combo[0]].symbol;
        break;
      }
    }
  }

  void resetGame() {
    setState(() {
      board = List.generate(9, (index) => Cell(index: index));
      isXTurn = true;
      xPositions = [];
      oPositions = [];
      moveCount = 0;
      winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Infinite Tic Tac Toe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF333333),
      ),
      // Use SingleChildScrollView to fix the overflow
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    winner != null
                        ? 'Player $winner wins!'
                        : 'Player ${isXTurn ? 'X' : 'O'}\'s turn',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: winner != null ? Colors.green : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Each player can only have 3 symbols at a time',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 320, // Fixed width for the board
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: 9,
                        shrinkWrap:
                            true, // Important to prevent nested scroll issues
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemBuilder: (context, index) {
                          return _buildCell(index);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayerInfo('X', xPositions),
                    const SizedBox(width: 40),
                    _buildPlayerInfo('O', oPositions),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Reset Game',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Move Count: $moveCount',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    Cell cell = board[index];
    bool isNextToBeRemoved = false;

    // Check if this cell contains the oldest move for the current player
    if (cell.symbol != null) {
      List<int> positions = cell.symbol == 'X' ? xPositions : oPositions;
      if (positions.isNotEmpty && positions[0] == index) {
        isNextToBeRemoved = true;
      }
    }

    return GestureDetector(
      onTap: () => makeMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isNextToBeRemoved
              ? Border.all(color: Colors.orange, width: 2.0)
              : Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: cell.symbol != null
              ? Text(
                  cell.symbol!,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: cell.symbol == 'X'
                        ? const Color(0xFF0066CC)
                        : const Color(0xFFCC3300),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String player, List<int> positions) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              player == 'X' ? const Color(0xFF0066CC) : const Color(0xFFCC3300),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Player $player',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: player == 'X'
                  ? const Color(0xFF0066CC)
                  : const Color(0xFFCC3300),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${positions.length}/3 symbols',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class Cell {
  final int index;
  String? symbol;

  Cell({required this.index, this.symbol});
}
