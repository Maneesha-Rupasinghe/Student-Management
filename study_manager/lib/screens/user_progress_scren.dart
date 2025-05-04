import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart';

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({super.key});

  @override
  _UserProgressScreenState createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> quizResults = [];
  Map<String, dynamic> overallResults = {};

  @override
  void initState() {
    super.initState();
    _fetchQuizResults();
  }

  Future<void> _fetchQuizResults() async {
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      print('No access token found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No access token found. Please log in.')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.4:8000/api/quiz/results_progress/');
    print('Requesting: $url with token: Bearer $token');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          overallResults = data['overall'] as Map<String, dynamic>;
          quizResults = (data['subjects'] as List).cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load quiz results: ${response.statusCode} - ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error fetching quiz results: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Map<String, Map<String, double?>> _groupResultsBySubject() {
    final groupedResults = <String, Map<String, double?>>{};
    for (var result in quizResults) {
      final subject = result['subject'] as String;
      final levels = result['levels'] as Map<String, dynamic>;
      groupedResults[subject] = {
        'Beginner':
            levels['Beginner'] != null
                ? double.tryParse(
                  (levels['Beginner'] as String).replaceAll('%', ''),
                )
                : null,
        'Intermediate':
            levels['Intermediate'] != null
                ? double.tryParse(
                  (levels['Intermediate'] as String).replaceAll('%', ''),
                )
                : null,
        'Advanced':
            levels['Advanced'] != null
                ? double.tryParse(
                  (levels['Advanced'] as String).replaceAll('%', ''),
                )
                : null,
      };
    }
    return groupedResults;
  }

  @override
  Widget build(BuildContext context) {
    final groupedResults = _groupResultsBySubject();
    final overallData = <PieChartSectionData>[];
    if (overallResults.isNotEmpty) {
      final levels = ['Beginner', 'Intermediate', 'Advanced'];
      double total = 0;
      for (var level in levels) {
        final value = overallResults[level];
        if (value != null) {
          total += double.parse(value.replaceAll('%', ''));
        }
      }
      for (var level in levels) {
        final value = overallResults[level];
        if (value != null) {
          final percentage =
              double.parse(value.replaceAll('%', '')) / total * 100;
          overallData.add(
            PieChartSectionData(
              color:
                  level == 'Beginner'
                      ? Colors.blue
                      : level == 'Intermediate'
                      ? Colors.green
                      : Colors.red,
              value: percentage,
              title: '$level\n${value}',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Progress',
          style: TextStyle(color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB4EBE6), Color(0xFFB4EBE6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            groupedResults.isEmpty && overallResults.isEmpty
                ? const Center(child: Text('No quiz results available'))
                : Column(
                  children: [
                    if (overallResults.isNotEmpty)
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overall Progress',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3674B5),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: overallData,
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: groupedResults.length,
                        itemBuilder: (context, index) {
                          final subject = groupedResults.keys.elementAt(index);
                          final levels = {
                            'Beginner',
                            'Intermediate',
                            'Advanced',
                          };
                          final data = groupedResults[subject]!;
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subject: $subject',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3674B5),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 200,
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY: 100,
                                        barTouchData: BarTouchData(
                                          enabled: false,
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                switch (value.toInt()) {
                                                  case 0:
                                                    return const Text(
                                                      'Beginner',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF080B0B,
                                                        ),
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  case 1:
                                                    return const Text(
                                                      'Intermediate',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF080B0B,
                                                        ),
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  case 2:
                                                    return const Text(
                                                      'Advanced',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF080B0B,
                                                        ),
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  default:
                                                    return const Text('');
                                                }
                                              },
                                              reservedSize: 30,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget:
                                                  (value, meta) => Text(
                                                    '${value.toInt()}%',
                                                    style: const TextStyle(
                                                      color: Color(0xFF080B0B),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              reservedSize: 40,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                        ),
                                        barGroups:
                                            levels.map((level) {
                                              final percentage =
                                                  data[level] ?? 0;
                                              return BarChartGroupData(
                                                x: levels.toList().indexOf(
                                                  level,
                                                ),
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: percentage ?? 0,
                                                    color: const Color(
                                                      0xFF3674B5,
                                                    ),
                                                    width: 20,
                                                    backDrawRodData:
                                                        BackgroundBarChartRodData(
                                                          show: true,
                                                          toY: 100,
                                                          color: Colors.grey
                                                              .withOpacity(0.3),
                                                        ),
                                                  ),
                                                ],
                                                showingTooltipIndicators: [0],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
