let
  raid0 = ''
    DEVICE partitions
    ARRAY /dev/md0 metadata=1.2 name=lserver:0 UUID=fdb4cf1b:984be78b:5b545c50:3231a157
    MAILADDR somebody@example.com
  '';
in
{
  boot.swraid = {
    enable = true;
    mdadmConf = raid0;
  };
}
