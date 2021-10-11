// import 'package:maliye_app/config/icons.dart';
// import 'package:maliye_app/providers/index_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';

// class MyBottomNavigationBar extends StatelessWidget {
//   final ValueChanged<int> onTap;

//   const MyBottomNavigationBar({this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<IndexProvider, int>(
//       builder: (_, int index, __) {
//         return CustomBottomBar(currentIndex: index);
//       },
//       selector: (_, model) => model.getSelectedIndex,
//     );
//   }
// }

// class CustomBottomBar extends StatefulWidget {
//   const CustomBottomBar({
//     Key key,
//     @required this.currentIndex,
//   }) : super(key: key);

//   final int currentIndex;

//   @override
//   _CustomBottomBarState createState() => _CustomBottomBarState();
// }

// class _CustomBottomBarState extends State<CustomBottomBar> {
//   @override
//   Widget build(BuildContext context) {
//     final state = Provider.of<IndexProvider>(context);
//     return Container(
//       margin: const EdgeInsets.all(10),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: BottomAppBar(
//           color: Theme.of(context).primaryColor,
//           elevation: 2.0,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.max,
//             children: List.generate(
//               tabBarData.length,
//               (i) {
//                 return Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       final state =
//                           Provider.of<IndexProvider>(context, listen: false);
//                       state.tabBarPageController.jumpToPage(i);
//                       setState(() {
//                         state.setIndex = i;
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
//                       child: buildContainerBottomNav(
//                         tabBarData[i]['image'],
//                         tabBarData[i]['title'],
//                         isSelected: state.getSelectedIndex == i,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildContainerBottomNav(
//     String icon,
//     String label, {
//     bool isSelected = false,
//   }) {
//     Size size = MediaQuery.of(context).size;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SvgPicture.asset(
//           icon,
//           color: isSelected ? Colors.white : const Color(0xffB5D8FF),
//           height: size.height * 0.03,
//         ),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           maxLines: 1,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xffB5D8FF),
//             fontWeight: FontWeight.w600,
//             fontSize: size.height * 0.015,
//           ),
//         ),
//       ],
//     );
//   }
// }
