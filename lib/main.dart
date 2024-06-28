import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Sudoku(),
    );
  }
}

class Sudoku extends StatefulWidget {
  const Sudoku({super.key});

  @override
  State<Sudoku> createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final puzzleNotifier = PuzzleNotifier(null);
    final listNotifier = ListNotifier();

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Ordenar de menor a mayor',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Movimientos: '),
                  TextSpan(
                      text: '0',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue)),
                  const TextSpan(text: ' | '),
                  const TextSpan(text: 'Max intentos: '),
                  TextSpan(
                      text: '40',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue)),
                ]),
              ),
              _SquartList(
                  puzzleNotifier: puzzleNotifier, listNotifier: listNotifier),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquartList extends StatelessWidget {
  const _SquartList({
    super.key,
    required this.puzzleNotifier,
    required this.listNotifier,
  });
  final PuzzleNotifier puzzleNotifier;
  final ListNotifier listNotifier;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.7,
      width: size.width * .8,
      child: ListenableBuilder(
        builder: (context, child) {
          List<Widget> childrenRow = [];
          for (int row = 0; row < listNotifier.matrix.length; row++) {
            List<Widget> childrenCol = [];
            for (int col = 0; col < listNotifier.matrix[row].length; col++) {
              final item = listNotifier.matrix[row][col];  
              childrenCol.add(Container(
                padding: const EdgeInsets.all(3),
                width: size.width * .2,
                height: size.width * .2,
                child: (item != 0) ? _ItemPuzzle(
                  listNotifier: listNotifier,
                  position: [row, col],
                  puzzleNotifier: puzzleNotifier,
                ) : const SizedBox(),
              ));
            }
            childrenRow.add(Row(
              children: childrenCol,
            ));
          }

          return Column(
            children: childrenRow,
          );
        },
        listenable: listNotifier,
      ),
    );
  }
}

class _ItemPuzzle extends StatefulWidget {
  const _ItemPuzzle(
      {super.key,
      required this.puzzleNotifier,
      required this.listNotifier,
      required this.position});

  final List<int> position;
  final PuzzleNotifier puzzleNotifier;
  final ListNotifier listNotifier;

  @override
  State<_ItemPuzzle> createState() => _ItemPuzzleState();
}

class _ItemPuzzleState extends State<_ItemPuzzle> {
  Color colorCard = Colors.blue;
  late final PuzzleNotifier puzzleNotifier;
  late final ListNotifier listNotifier;
  late final int row;
  late final int col;
  late final int item;

  @override
  void initState() {
    row = widget.position[0];
    col = widget.position[1];
    item = widget.listNotifier.matrix[row][col];
    puzzleNotifier = widget.puzzleNotifier;
    listNotifier = widget.listNotifier;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (puzzleNotifier.item == null) {
          _markAvailablePosition();
        } else if (puzzleNotifier.item == item) {
          puzzleNotifier.availableItems = [];
          puzzleNotifier.item = null;
        } else {
         _moveItem();
        }
      },
      child: ListenableBuilder(
          listenable: puzzleNotifier,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: puzzleNotifier.item == item
                    ? Colors.red
                    : puzzleNotifier.availableItems.contains(item)
                        ? Colors.green
                        : Colors.blue,
              ),
              child: child,
            );
          },
          child: Center(
              child: Text(
            item.toString(),
            style: TextStyle(
                color: Colors.white,
                fontSize: lerpDouble(20, 30, width / 1000),
                fontWeight: FontWeight.bold),
          ))),
    );
  }

  void _markAvailablePosition() {
    final List directions = [
      [-1, 0],
      [0, -1],
      [1, 0],
      [0, 1]
    ];
    for (var direction in directions) {
      final int rowDirection = (row + direction[0]).toInt();
      final int colDirection = (col + direction[1]).toInt();
      if (rowDirection >= 0 &&
          rowDirection < listNotifier.matrix.length &&
          colDirection >= 0 &&
          colDirection < listNotifier.matrix[rowDirection].length) {
        int value = listNotifier.matrix[rowDirection][colDirection];
        puzzleNotifier.availableItems.add(value);
      }
    }
    puzzleNotifier.item = item;
  }
  
  void _moveItem() {
    if (puzzleNotifier.availableItems.contains(item)) {
      listNotifier.matrix[row][col] = puzzleNotifier.item!;
      listNotifier.matrix[puzzleNotifier.item! - 1][col] = item;
      puzzleNotifier.availableItems.remove(item);
      puzzleNotifier.item = null;
    }
  }
}

class PuzzleNotifier extends ChangeNotifier {
  PuzzleNotifier(this._item);
  List<int> availableItems = [];
  int? _item;

  set item(int? value) {
    _item = value;
    notifyListeners();
  }

  int? get item => _item;
}

class ListNotifier extends ChangeNotifier {
  ListNotifier();
  List<List<int>> _matrix = List<List<int>>.generate(4, (indexRow) {
    return List<int>.generate(4, (indexCol) {
      return indexRow * 4 + indexCol + 1;
    });
  });


  set matrix(List<List<int>> value) {
    _matrix = value;
    notifyListeners();
  }

  List<List<int>> get matrix => _matrix;
}
