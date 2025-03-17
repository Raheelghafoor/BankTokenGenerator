import 'package:flutter/material.dart';
import 'package:token_reminder/Screen/tokenDetails.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<String> serviceList = [
    "Account Opening",
    "Cash Deposit & Withdrawal",
    "Cheque Deposit",
    "Loan Consultation",
    "Card Issuance & Replacement",
    "Foreign Exchange Services"
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          title: const Text(
            "Welcome",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: size.height * 0.05),
            physics: AlwaysScrollableScrollPhysics(),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: size.width * 0.05,
              runSpacing: size.height * 0.05,
              children: List.generate(
                serviceList.length,
                (int index) => GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TokenDetails(serviceName: serviceList[index],)));
                  },
                  child: Container(
                    height: size.height * 0.2,
                    width: size.width * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.red, width: 2)),
                    child: Center(
                      child: Text(
                        serviceList[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
