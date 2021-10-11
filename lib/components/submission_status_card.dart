import 'package:maliye_app/models/document_submission.dart';
import 'package:flutter/material.dart';

class SubmissionStatusCard extends StatelessWidget {
  const SubmissionStatusCard({
    Key key,
    this.isLast = false,
    this.label,
    this.status,
  }) : super(key: key);

  final String label;
  final Status status;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status.getBackgroundColor,
              border: status == null
                  ? Border.all(width: 3, color: Color(0xFFE3E3E3))
                  : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: status.getIcon),
          ),
        ],
      ),
    );
  }
}
