prev: {
  chinalist-raw = (prev.callPackage ./chinalist { });
  chinalist-smartdns = (prev.callPackage ./chinalist { format = "smartdns"; });
  chinalist-overture = (prev.callPackage ./chinalist { format = "overture"; });
  maxmind-geoip = (prev.callPackage ./maxmind-geoip { });
}
