import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class ChartDemo extends StatefulWidget
{
  @override
  ChartDemoState createState() =>ChartDemoState();

}
class ChartDemoState extends State<ChartDemo>
{
  List<_ShareData> monthlydata;
  List<_ShareData> chartdata;
  String type="WEEKLY";
  createchart(format,company,day) async
  {
    print("Chart Data Called");
    Uri url = Uri.parse("https://www.alphavantage.co/query?function="+format+"&symbol="+company+"&outputsize=full&datatype=json&apikey=D4FDDX776V0FDNYD");
    var response = await http.get(url);
    if(response.statusCode==200)
      {
        var json = jsonDecode(response.body);
        if(format=="TIME_SERIES_MONTHLY")
          {
             var data = json["Monthly Time Series"];
             List<_ShareData> temp = new List<_ShareData>();
             (data as Map<String, dynamic>).forEach((key, value) {
               temp.add(_ShareData(key, double.parse(value["4. close"])));
             });
             setState(() {
               chartdata=temp;
             });
          }
        else if(format=="TIME_SERIES_DAILY")
          {
            var data = json["Time Series (Daily)"];
            List<_ShareData> temp = new List<_ShareData>();
            int count=1;
            (data as Map<String, dynamic>).forEach((key, value) {
              if(count>day)
                {
                  return;
                }
              temp.add(_ShareData(key, double.parse(value["4. close"])));
              count++;
            });
            setState(() {
              chartdata=temp;
            });
          }
        else
          {
            var data = json["Weekly Time Series"];
            List<_ShareData> temp = new List<_ShareData>();
            (data as Map<String, dynamic>).forEach((key, value) {
              temp.add(_ShareData(key, double.parse(value["4. close"])));
            });
            setState(() {
              chartdata=temp;
            });
          }
      }
  }

  var drpvalue = null;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Chart"),
     ),
     body: Column(
         children: [
           Padding(
             padding: const EdgeInsets.all(15.0),
             child: DropdownButton(
               value: drpvalue,
               hint: Text("Select Company Name"),
               items: <String>['TSLA', 'APPL', 'GOOG', 'AMZN'].map((String value) {
                 return DropdownMenuItem<String>(
                   value: value,
                   child: new Text(value),
                 );
               }).toList(),
               onChanged: (value){
                 setState(() {
                   drpvalue = value;
                   createchart("TIME_SERIES_WEEKLY",drpvalue,5);
                 });
               },
             ),
           ),
           Row(
             children: [
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: ElevatedButton(
                   onPressed: (){
                     setState(() {
                       type="WEEKLY";
                     });
                     createchart("TIME_SERIES_WEEKLY",drpvalue,7);
                   },
                   child: Text("WEEKLY"),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: ElevatedButton(
                   onPressed: (){
                     setState(() {
                       type = "MONTHLY";
                       createchart("TIME_SERIES_MONTHLY",drpvalue,31);
                     });
                   },
                   child: Text("Monthly"),
                 ),
               ),
             ],
           ),
           Row(
             children: [
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: InkWell(
                   splashColor: Colors.cyan,
                   child: Text("5D"),
                   onTap: (){
                     createchart("TIME_SERIES_DAILY",drpvalue,5);
                   },
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: InkWell(
                   splashColor: Colors.cyan,
                   child: Text("1M"),
                   onTap: (){
                     createchart("TIME_SERIES_DAILY",drpvalue,31);
                   },
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: InkWell(
                   splashColor: Colors.cyan,
                   child: Text("6M"),
                   onTap: (){
                     createchart("TIME_SERIES_DAILY",drpvalue,180);
                   },
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: InkWell(
                   splashColor: Colors.cyan,
                   child: Text("1Y"),
                   onTap: (){
                     createchart("TIME_SERIES_DAILY",drpvalue,365);
                   },
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: InkWell(
                   splashColor: Colors.cyan,
                   child: Text("5Y"),
                   onTap: (){
                     createchart("TIME_SERIES_DAILY",drpvalue,1825);
                   },
                 ),
               )
             ],
           ),
           (chartdata!=null)?Container(
             width: MediaQuery.of(context).size.width,
             height: 300,
             // color: Colors.black12,
             child: Column(
                 children: [
               //Initialize the chart widget
                SfCartesianChart(
                     primaryXAxis: CategoryAxis(
                       interval: 1,
                       visibleMaximum:15.0,
                     ),
                     // Chart title
                     title: ChartTitle(text: 'Report : '+drpvalue+" BY "+type),
                     // Enable legend
                     //legend: Legend(isVisible: true),
                     zoomPanBehavior: ZoomPanBehavior(
                       enablePanning: true,
                     ),
                     // Enable tooltip
                     tooltipBehavior: TooltipBehavior(enable: true),
                     series: <ChartSeries<_ShareData, String>>[
                       LineSeries<_ShareData, String>(
                           dataSource: chartdata,
                           xValueMapper: (_ShareData sales, _) => sales.date,
                           yValueMapper: (_ShareData sales, _) => sales.sharevalue,
                           name: 'Share',
                           // Enable data label
                           dataLabelSettings: DataLabelSettings(isVisible: true))
                     ]),
             ]),
           ):Center(child: CircularProgressIndicator())
         ],
       ),
   );
  }
}
class _ShareData {
  _ShareData(this.date, this.sharevalue);

  final String date;
  final double sharevalue;
}