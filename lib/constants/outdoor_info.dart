import 'package:flutter/material.dart';

class OutsideRegion {
  final String regionID;
  final List<Offset> regionPolygonOverview;
  final List<Offset> regionPolygonSublocation;
  final String regionName;
  final String imageName;
  final String regionLocation;
  final String regionIndicator;
  final bool overviewMap;
  bool isSelected;

  OutsideRegion(
      {required this.regionID,
      required this.regionPolygonOverview,
      required this.regionPolygonSublocation,
      required this.regionName,
      required this.imageName,
      required this.regionLocation,
      required this.regionIndicator,
      required this.overviewMap,
      required this.isSelected});
}

List<OutsideRegion> outsideRegions = [
  OutsideRegion(
    regionID: "gamlaSkogen",
    regionPolygonOverview: [
      const Offset(0.3132531832201772, 0.1516325670978476),
      const Offset(0.3317890032503901, 0.1432071943568417),
      const Offset(0.3395122615963122, 0.13231585886237066),
      const Offset(0.3395122615963122, 0.12142452336789966),
      const Offset(0.34878017161141867, 0.11731458544545777),
      const Offset(0.3619097107994862, 0.1119716661462833),
      const Offset(0.3615235478821901, 0.09799787720998088),
      const Offset(0.3568895928746369, 0.07827017518225977),
      const Offset(0.34955249744601086, 0.062446914180858494),
      const Offset(0.3375814470098317, 0.04950060972516654),
      const Offset(0.3209764415660992, 0.040458746295794365),
      const Offset(0.30668841362614346, 0.040458746295794365),
      const Offset(0.29085573401700326, 0.04415769042599207),
      const Offset(0.2819739869191929, 0.05011710041353282),
      const Offset(0.26884444773112537, 0.06141942970024803),
      const Offset(0.2564872343776501, 0.07785918139001559),
      const Offset(0.25030862770091244, 0.09203846722244012),
      const Offset(0.2437438581068787, 0.10745073443159722),
      const Offset(0.2429715322722865, 0.12327399543299851),
      const Offset(0.2518532793700969, 0.13375433713522533),
      const Offset(0.2703890994003098, 0.14505666642194054),
      const Offset(0.29201422276889155, 0.1516325670978476),
      const Offset(0.3113223686336967, 0.15245455468233596)
    ],
    regionPolygonSublocation: [],
    regionName: "Gamla Skogen",
    imageName: "GamlaSkogenOverview",
    regionLocation: "kjugge",
    regionIndicator: "1",
    overviewMap: true,
    isSelected: false,
  ),
  OutsideRegion(
    regionID: "nyeSkogen",
    regionPolygonOverview: [
      const Offset(0.3406242328211775, 0.12041964491348289),
      const Offset(0.3586074314490239, 0.11457145023776051),
      const Offset(0.36110509792511375, 0.10659663931632087),
      const Offset(0.3995691616568963, 0.08772292013558038),
      const Offset(0.41655329369430677, 0.08400134170557522),
      const Offset(0.5054702202431028, 0.09569773105702001),
      const Offset(0.5209557523948596, 0.10207757979417173),
      const Offset(0.5569221496505524, 0.12626783958920532),
      const Offset(0.5619174826027319, 0.1398250181556527),
      const Offset(0.5549240164696805, 0.15311636969138548),
      const Offset(0.44552622481694826, 0.1847497863464294),
      const Offset(0.4190509601703966, 0.18714222962286128),
      const Offset(0.37409296360078054, 0.18209151603928286),
      const Offset(0.34761769895422895, 0.1735850510564139),
      const Offset(0.3441209658877032, 0.16135700764353975),
      const Offset(0.3396251662307416, 0.13158438020349844)
    ],
    regionPolygonSublocation: [],
    regionName: "Nye Skogen",
    imageName: "NyeSkogenOverview",
    regionLocation: "kjugge",
    regionIndicator: "2",
    overviewMap: false,
    isSelected: false,
  )
];


