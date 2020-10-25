prev: {
  chinalist-raw = (prev.callPackage ./chinalist { });
  chinalist-smartdns = (prev.callPackage ./chinalist { format = "smartdns"; });
  maxmind-geoip = (prev.callPackage ./maxmind-geoip { });
}
