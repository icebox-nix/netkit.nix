prev: {
  yacd = (prev.callPackage ./yacd { });
  snapdrop = (prev.callPackage ./snapdrop { });
  atomdns = (prev.callPackage ./atomdns { });
  overture = (prev.callPackage ./overture { });
  dcompass = (prev.callPackage ./dcompass { });
  dcompass-bin = (prev.callPackage ./dcompass-bin { });
}
