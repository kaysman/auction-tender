import 'dart:developer';

import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/exceptions/error_indicator.dart';
import 'package:maliye_app/models/preferences.dart';
import 'package:maliye_app/models/organization.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterTender extends StatefulWidget {
  const FilterTender({
    Key key,
    this.preferences,
    this.repository,
    @required this.tenderId,
  }) : super(key: key);

  final TenderListProvider repository;
  final TenderPreferences preferences;
  final int tenderId;

  @override
  _FilterTenderState createState() => _FilterTenderState();
}

class _FilterTenderState extends State<FilterTender> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TenderListProvider get _repository => widget.repository;
  bool _isLoading = true;
  dynamic _error;

  List<Organization> organizations = [];
  Organization selectedOrganization;
  int selectedOrganizationId;

  List<BusinessLine> lines = [];
  BusinessLine selectedLine;
  int selectedLineId;

  TenderPreferences get _previousPreferences => widget.preferences;

  @override
  void initState() {
    _fetchFilterOptions();
    super.initState();

    if (_previousPreferences != null) {
      selectedOrganization = _previousPreferences.organization;
      selectedLine = _previousPreferences.lines;

      selectedOrganizationId = selectedOrganization?.id;
      selectedLineId = selectedLine?.id;
    }
  }

  Future<void> _fetchFilterOptions() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
        selectedOrganization = null;
        selectedLine = null;
      });
    }

    try {
      final result = await _repository.getHelperData(widget.tenderId);
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
            ? Center(
                child: const CircularProgressIndicator(),
              )
            : _error != null
                ? ErrorIndicator(error: _error, onTryAgain: _fetchFilterOptions)
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Bäsleşik",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Satyn alyjy",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: selectedOrganizationId,
                          onChanged: (v) {
                            setState(() => selectedOrganizationId = v);
                          },
                          items: organizations.map((org) {
                            return DropdownMenuItem(
                              child: Text(
                                org.name,
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: org.id,
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
                                    selectedOrganizationId = null;
                                  });
                                },
                                child: SvgPicture.asset(
                                  "assets/svg/cancel.svg",
                                  height: 12,
                                  width: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Hyzmat ýa-da söwdanyň görnüşleri ",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: line.id,
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
                                    selectedLineId = null;
                                  });
                                },
                                child: SvgPicture.asset(
                                  "assets/svg/cancel.svg",
                                  height: 12,
                                  width: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: FilterButtons(
        resetBtnOnPressed: () {
          setState(() {
            selectedOrganizationId = null;
            selectedLineId = null;
          });
        },
        searchBtnOnPressed: () => _sendResultsBack(),
      ),
    );
  }

  void _sendResultsBack() {
    // org
    var org = organizations.where((el) => el.id == selectedOrganizationId);
    var orgData = org.isEmpty ? null : org.first;

    // businessway
    var line = lines.where((el) => el.id == selectedLineId);
    var lineData = line.isEmpty ? null : line.first;

    Navigator.of(context).pop(
      TenderPreferences(
        organization: orgData,
        lines: lineData,
      ),
    );
  }
}

class FilterButtons extends StatelessWidget {
  const FilterButtons({
    Key key,
    this.resetBtnOnPressed,
    this.searchBtnOnPressed,
  }) : super(key: key);

  final Function() resetBtnOnPressed;
  final Function() searchBtnOnPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(
        left: 6,
        right: 6,
        bottom: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.width,
            child: ElevatedButton(
              onPressed: resetBtnOnPressed,
              child: Text(
                "Asyl tertipde",
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(primary: const Color(0xFFDEDEDE)),
            ),
          ),
          SizedBox(
            width: size.width,
            child: ElevatedButton(
              onPressed: searchBtnOnPressed,
              child: Text("Gözlemek"),
            ),
          ),
        ],
      ),
    );
  }
}
