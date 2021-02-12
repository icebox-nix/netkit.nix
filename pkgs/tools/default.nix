prev: {
  yacd = (prev.callPackage ./yacd { });
  atomdns = (prev.callPackage ./atomdns { });
  overture = (prev.callPackage ./overture { });
  dcompass = (prev.callPackage ./dcompass { });
  dcompass-bin = (prev.callPackage ./dcompass-bin { });
  subconverter = (prev.callPackage ./subconverter { });
}
