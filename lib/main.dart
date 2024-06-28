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
  final puzzleNotifier = PuzzleNotifier(null);
  final listNotifier = ListNotifier();

  @override
  void initState() {
    listNotifier.generateMatrix(4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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

class _SquartList extends StatefulWidget {
  const _SquartList({
    super.key,
    required this.puzzleNotifier,
    required this.listNotifier,
  });
  final PuzzleNotifier puzzleNotifier;
  final ListNotifier listNotifier;

  @override
  State<_SquartList> createState() => _SquartListState();
}

class _SquartListState extends State<_SquartList> {
  @override
  void initState() {
    final availablePositions = widget.listNotifier
        .generateAvailablePosition(widget.listNotifier.zeroPosition);
    widget.puzzleNotifier.availableItems = availablePositions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.7,
      width: size.width * .8,
      child: ListenableBuilder(
        builder: (context, child) {
          List<Widget> childrenRow = [];
          for (int row = 0; row < widget.listNotifier.matrix.length; row++) {
            List<Widget> childrenCol = [];
            for (int col = 0;
                col < widget.listNotifier.matrix[row].length;
                col++) {
              childrenCol.add(Container(
                padding: const EdgeInsets.all(3),
                width: size.width * .2,
                height: size.width * .2,
                child: _ItemPuzzle(
                  listNotifier: widget.listNotifier,
                  position: [row, col],
                  puzzleNotifier: widget.puzzleNotifier,
                ),
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
        listenable: widget.listNotifier,
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
  late final int rowCurrentItem;
  late final int colCurrentItem;
  late final int item;

  @override
  void initState() {
    rowCurrentItem = widget.position[0];
    colCurrentItem = widget.position[1];
    puzzleNotifier = widget.puzzleNotifier;
    listNotifier = widget.listNotifier;
    item = listNotifier.matrix[rowCurrentItem][colCurrentItem];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        final itemSelected =
            puzzleNotifier.getSelectedItem(listNotifier.matrix);
        if (itemSelected == null) {
          if (puzzleNotifier.availableItems.contains(item)) {
            puzzleNotifier.itemPosition = widget.position;
          }
          return;
        }
        if (item == 0) {
          _moveItem();
          return;
        }
        if (itemSelected == item) {
          puzzleNotifier.itemPosition = null;
        }
      },
      child: ListenableBuilder(
          listenable: puzzleNotifier,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _getColorCard(),
              ),
              child: item == 0 ? const SizedBox() : child,
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

  void _moveItem() {
    // List<List<int>> newMatrix = listNotifier.matrix;

    // newMatrix[rowCurrentItem][colCurrentItem] = item;

    // newMatrix[rowZero][colZero] = item;
    // listNotifier.matrix = newMatrix;
    // listNotifier.zeroPosition = [rowCurrentItem, colCurrentItem];
    // puzzleNotifier.item = null;
  }

  Color _getColorCard() {
    final int? itemSelected = puzzleNotifier.getSelectedItem(listNotifier.matrix);

    if (itemSelected == item) {
      return Colors.red;
    }
    if (puzzleNotifier.availableItems.contains(item)) {
      return Colors.green;
    }
    if (itemSelected != null && item == 0) {
      return Colors.grey;
    }
    if (item == 0) {
      return Colors.transparent;
    }

    return Colors.blue;
  }
}

class PuzzleNotifier extends ChangeNotifier {
  PuzzleNotifier(this._itemPosition);
  List<int> availableItems = [];
  List<int>? _itemPosition;

  set itemPosition(List<int>? value) {
    _itemPosition = value;
    notifyListeners();
  }

  List<int>? get itemPosition => _itemPosition;

  int? getSelectedItem(List<List<int>> matrix) {
    int? itemSelected = -1;
    if (itemPosition != null) {
      itemSelected = matrix[itemPosition![0]][itemPosition![1]];
    }
    return itemSelected;
  }
}

class ListNotifier extends ChangeNotifier {
  ListNotifier();
  List<List<int>> _matrix = [];
  List<int> _zeroPosition = [];

  set matrix(List<List<int>> value) {
    _matrix = value;
    notifyListeners();
  }

  List<List<int>> get matrix => _matrix;

  set zeroPosition(List<int> value) {
    _zeroPosition = value;
    notifyListeners();
  }

  List<int> get zeroPosition => _zeroPosition;

  List<int> generateAvailablePosition(List<int> zeroPosition) {
    List<List<int>> directions = [
      [-1, 0],
      [0, -1],
      [1, 0],
      [0, 1]
    ];
    List<int> availablePositions = [];
    for (var direction in directions) {
      final int rowDirection = (zeroPosition[0] + direction[0]).toInt();
      final int colDirection = (zeroPosition[1] + direction[1]).toInt();
      if (rowDirection >= 0 &&
          rowDirection < matrix.length &&
          colDirection >= 0 &&
          colDirection < matrix[rowDirection].length) {
        int value = matrix[rowDirection][colDirection];
        availablePositions.add(value);
      }
    }
    return availablePositions;
  }

  void generateMatrix(int size) {
    int maxNumber = size * size;
    List<int> numbers = List<int>.generate(maxNumber, (index) => index);
    numbers.shuffle();
    for (int i = 0; i < size; i++) {
      List<int> row = [];
      for (int j = 0; j < size; j++) {
        if (numbers[i * size + j] == 0) {
          _zeroPosition = [i, j];
        }
        row.add(numbers[i * size + j]);
      }
      matrix.add(row);
    }
  }
}
