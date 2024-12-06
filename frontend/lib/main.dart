import 'package:aoc/day.dart';
import 'package:aoc_frontend/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_builder/timer_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AoC Solutions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

final class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AocBloc(),
      child: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: SelectionGuide(),
        ),
      ),
    );
  }
}

final class SelectionGuide extends StatelessWidget {
  const SelectionGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AocBloc, AocState>(builder: (context, state) {
      final children = <Widget>[
        const DaySelection(),
        const Divider(),
      ];

      if (state.day != null) {
        if (state.isMultipart) {
          children.add(const PartSelection());
          children.add(const Divider());
        }

        if (state.isReady) {
          children.add(const Expanded(child: ActionArea()));
        } else if (state.runStates.isNotEmpty) {
          children.add(const Expanded(child: RunningState()));
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: children,
      );
    });
  }
}

final class DaySelection extends StatelessWidget {
  const DaySelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      runSpacing: 3.0,
      children: [
        for (final day in availableDays) DayCard(day),
      ],
    );
  }
}

final class DayCard extends StatelessWidget {
  final int day;

  const DayCard(
    this.day, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AocBloc bloc = BlocProvider.of(context);
    return BlocBuilder(
      bloc: bloc,
      builder: (context, AocState state) => ChoiceChip(
        label: Text('Day $day'),
        selected: state.day == day,
        onSelected: (newValue) {
          if (newValue) {
            bloc.add(DaySelected(day));
          }
        },
      ),
    );
  }
}

final class PartSelection extends StatelessWidget {
  const PartSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final AocBloc bloc = BlocProvider.of(context);
    return BlocBuilder(
      bloc: bloc,
      builder: (context, AocState state) {
        return Row(
          children: [
            ChoiceChip(
              label: const Text('Part 1'),
              selected: state.enablePartOne,
              onSelected: (isSelected) => bloc.add(PartOneToggled(isSelected)),
            ),
            const SizedBox(width: 5),
            ChoiceChip(
              label: const Text('Part 2'),
              selected: state.enablePartTwo,
              onSelected: (isSelected) => bloc.add(PartTwoToggled(isSelected)),
            ),
          ],
        );
      },
    );
  }
}

final class ActionArea extends StatelessWidget {
  const ActionArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () =>
            BlocProvider.of<AocBloc>(context).add(const OpenFilePicker()),
        child: const Text('Select input file'),
      ),
    );
  }
}

final class RunningState extends StatelessWidget {
  const RunningState({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 30),
      child: Center(
        child: BlocBuilder<AocBloc, AocState>(
          builder: (context, state) {
            final children = state.runStates
                .map((s) => [
                      RunStateView(s),
                      const SizedBox(height: 10),
                    ])
                .flattened
                .toList();

            if (!state.isRunning) {
              children.add(IconButton(
                onPressed: () =>
                    BlocProvider.of<AocBloc>(context).add(const ClearResult()),
                icon: const Icon(Icons.undo),
              ));
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
          },
        ),
      ),
    );
  }
}

final class RunStateView extends StatelessWidget {
  final RunState state;

  const RunStateView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TimerBuilder.periodic(
          const Duration(milliseconds: 100),
          builder: (context) => Text(
            (state.endTime ?? DateTime.now())
                .difference(state.startTime)
                .toString(),
          ),
        ),
        const SizedBox(width: 10),
        ResultIndicator(state),
        const SizedBox(width: 10),
        ResultText(state),
      ],
    );
  }
}

final class ResultIndicator extends StatelessWidget {
  final RunState state;

  const ResultIndicator(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    if (state.isDone) {
      if (state.isSuccessful) {
        return const Icon(Icons.check_box, color: Colors.greenAccent);
      } else {
        return const Icon(Icons.error, color: Colors.red);
      }
    } else {
      return const CircularProgressIndicator();
    }
  }
}

final class ResultText extends StatelessWidget {
  final RunState state;

  const ResultText(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    if (state.isDone) {
      if (state.isSuccessful) {
        return Text(state.result!);
      } else {
        return Text('Error: ${state.error}');
      }
    } else {
      return const Offstage();
    }
  }
}
