import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/models/preferences.dart';
import 'package:maliye_app/models/helper.dart';
import 'package:maliye_app/models/organization.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:maliye_app/exceptions/error_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterAuction extends StatefulWidget {
  const FilterAuction({
    Key key,
    this.preferences,
    this.repository,
    @required this.auctionId,
  }) : super(key: key);

  final AuctionListProvider repository;
  final AuctionPreferences preferences;
  final int auctionId;

  @override
  _FilterAuctionState createState() => _FilterAuctionState();
}

class _FilterAuctionState extends State<FilterAuction> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuctionListProvider get _repository => widget.repository;
  bool _isLoading = true;
  dynamic _error;

  AuctionPreferences get _previousPreferences => widget.preferences;

  List<Region> regions = [];
  Region selectedRegion;
  int selectedRegionId;

  List<Organization> organizations = [];
  Organization selectedOrganization;
  int selectedOrganizationId;

  List<BusinessLine> lines = [];
  BusinessLine selectedLine;
  int selectedLineId;

  @override
  void initState() {
    _fetchFilterOptions();

    if (_previousPreferences != null) {
      selectedRegion = _previousPreferences.regions;
      selectedOrganization = _previousPreferences.organization;
      selectedLine = _previousPreferences.lines;

      selectedRegionId = selectedRegion?.id;
      selectedOrganizationId = selectedOrganization?.id;
      selectedLineId = selectedLine?.id;
    }

    super.initState();
  }

  Future<void> _fetchFilterOptions() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
        selectedRegion = null;
        selectedOrganization = null;
        selectedLine = null;
      });
    }

    try {
      final result = await _repository.getHelperData(widget.auctionId);
      List<Region> responseRegions = (result["regions"] as List)
          .map(
            (json) => Region.fromJson(json),
          )
          .toList();
      List<Organization> responseOrganizations =
          (result["organizations"] as List)
              .map(
                (json) => Organization.fromJson(json),
              )
              .toList();
      List<BusinessLine> responseLines = (result["lines"] as List)
          .map(
            (json) => BusinessLine.fromJson(json),
          )
          .toList();

      setState(() {
        regions = responseRegions;
        organizations = responseOrganizations;
        lines = responseLines;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return OrientationBuilder(
      builder: (context, orientation) {
        double btnTextSize = orientation == Orientation.landscape
            ? size.height * 0.03
            : size.width * 0.03;

        List<Widget> buttons = [
          SizedBox(
            width: orientation == Orientation.landscape
                ? (size.width / 2 - 60)
                : size.width,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedOrganizationId = null;
                  selectedRegionId = null;
                  selectedLineId = null;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Asyl tertipde",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: btnTextSize,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFDEDEDE),
              ),
            ),
          ),
          if (orientation == Orientation.landscape) const SizedBox(width: 14),
          SizedBox(
            width: orientation == Orientation.landscape
                ? size.width / 2
                : size.width,
            child: ElevatedButton(
              onPressed: () => _sendResultsBack(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Gözlemek",
                  style: TextStyle(
                    fontSize: btnTextSize,
                  ),
                ),
              ),
            ),
          ),
        ];

        return Scaffold(
          appBar: MyAppBar(
            context: context,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AppBarBack(AppBarBackType.Close),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? ErrorIndicator(
                        error: _error,
                        onTryAgain: _fetchFilterOptions,
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Bäsleşikli söwda",
                                style: TextStyle(
                                  fontSize: btnTextSize + 6,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              "Hasabynda saklaýjy",
                              style: TextStyle(
                                fontSize: btnTextSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: selectedOrganizationId,
                              onChanged: (v) =>
                                  setState(() => selectedOrganizationId = v),
                              items: organizations.map((org) {
                                return DropdownMenuItem(
                                  child: Text(
                                    org.name,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontSize: btnTextSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: org.id,
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              isDense: true,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                  maxWidth: 40,
                                  minHeight: 14,
                                  minWidth: 14,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedOrganizationId = null;
                                      });
                                    },
                                    child: buildCancelIcon(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Desgalaryň ýerleşýän ýeri",
                              style: TextStyle(
                                fontSize: btnTextSize - 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Welaýat ýa-da Aşgabat şäher",
                              style: TextStyle(
                                fontSize: btnTextSize - 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: selectedRegionId,
                              onChanged: (v) {
                                setState(() => selectedRegionId = v);
                              },
                              items: regions.map((region) {
                                return DropdownMenuItem(
                                  child: Text(
                                    region.value,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontSize: btnTextSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: region.id,
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                  maxWidth: 40,
                                  minHeight: 14,
                                  minWidth: 14,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedRegionId = null;
                                      });
                                    },
                                    child: buildCancelIcon(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Desganyň görnüşi",
                              style: TextStyle(
                                fontSize: btnTextSize - 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: selectedLineId,
                              onChanged: (v) {
                                setState(() => selectedLineId = v);
                              },
                              items: lines.map((line) {
                                return DropdownMenuItem(
                                  child: Text(
                                    line.name,
                                    overflow: TextOverflow.visible,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: btnTextSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: line.id,
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              isDense: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 0.0,
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                  maxWidth: 40,
                                  minHeight: 14,
                                  minWidth: 14,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedLineId = null;
                                      });
                                    },
                                    child: buildCancelIcon(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(
              left: 6,
              right: 6,
              bottom: 6,
            ),
            child: orientation == Orientation.landscape
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buttons,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: buttons,
                  ),
          ),
        );
      },
    );
  }

  void _sendResultsBack(BuildContext context) {
    // org
    var org = organizations.where((el) => el.id == selectedOrganizationId);
    var orgData = org.isEmpty ? null : org.first;

    // region
    var reg = regions.where((el) => el.id == selectedRegionId);
    var regData = reg.isEmpty ? null : reg.first;

    // businessway
    var line = lines.where((el) => el.id == selectedLineId);
    var lineData = line.isEmpty ? null : line.first;

    Navigator.of(context).pop(
      AuctionPreferences(
        organization: orgData,
        regions: regData,
        lines: lineData,
      ),
    );
  }

  buildCancelIcon() {
    return SvgPicture.asset(
      "assets/svg/cancel.svg",
      height: 12,
      width: 12,
      color: const Color(0xffa2a3a3),
    );
  }
}
