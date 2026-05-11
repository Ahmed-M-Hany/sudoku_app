import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'soduku.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  bool _isLoading = false;

  List<List<TextEditingController>> controllers = List.generate(
      9, (_) => List.generate(9, (_)=>TextEditingController(), growable: false),
      growable: false);

  Widget? buildBoard() {
    List<Expanded> board = [];
    for (int i = 0; i < 9; i++) {
      List<Expanded> tableRow = [];
      for (int j = 0; j < 9; j++) {
        double topWidth = (i % 3 == 0) ? 2.0 : 0.5;
        double bottomWidth = (i == 8) ? 2.0 : 0.0;
        double leftWidth = (j % 3 == 0) ? 2.0 : 0.5;
        double rightWidth = (j == 8) ? 2.0 : 0.0;

        tableRow.add(Expanded(
          child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: topWidth),
                  bottom: BorderSide(color: Colors.black, width: bottomWidth),
                  left: BorderSide(color: Colors.black, width: leftWidth),
                  right: BorderSide(color: Colors.black, width: rightWidth),
                ),
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textInputAction: TextInputAction.next,
                  maxLength: 1,
                  buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) => null,
                  onChanged: (_) => FocusScope.of(context).nextFocus(),
                  keyboardType: TextInputType.number,
                  controller: controllers[i][j],
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              )),
        ));
      }
      Row r = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: tableRow,
      );
      board.add(Expanded(child: r));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                board[0],
                board[1],
                board[2],
                board[3],
                board[4],
                board[5],
                board[6],
                board[7],
                board[8],
              ],
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              padding: const EdgeInsets.all(16.0),
            ),
            onPressed: _isLoading ? null : () async {
              List<List<int>> soduku =
                  List.generate(9, (_) => List.filled(9, 0, growable: false));
              for (int i = 0; i < 9; i++) {
                for (int j = 0; j < 9; j++) {
                  try {
                    soduku[i][j] = int.parse(controllers[i][j].text.toString());
                  } catch (e) {
                    soduku[i][j] = 0;
                  }
                }
              }

              setState(() {
                _isLoading = true;
              });

              try {
                final result = await compute(Solver.solve, soduku);

                setState(() {
                  for (int i = 0; i < 9; i++) {
                    for (int j = 0; j < 9; j++) {
                      controllers[i][j].text = result[i][j] == 0 ? '' : result[i][j].toString();
                    }
                  }
                  _isLoading = false;
                });
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text("SOLVE"),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    for (var row in controllers) {
                      for (var controller in row) {
                        controller.clear();
                      }
                    }
                  },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Clear Board"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sudoku Solver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: buildBoard()!,
        ),
      ),
    );
  }
}
