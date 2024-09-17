import 'package:flutter/material.dart';
import 'package:storedatalocal/utils/media_query_values.dart';

import '../header.dart';
import '../home_dashdoard.dart';
import '../overall_portfolio_card.dart';
import '../stock_widget.dart';

class HomeAdmin extends StatefulWidget {
  var id;

  HomeAdmin({ required this.id});

  @override
  State<HomeAdmin> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeAdmin> {
  late int id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.black,
        child: Row(
          children: [
            // const SideBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Header(id: id),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              OverallPortfolioCard(id: id,),
                              OverviewStatistic(id: id),
                            ],
                          ),
                          SizedBox(
                            width: context.width * 0.023,
                          ),
                          StockWidget(id: id,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
