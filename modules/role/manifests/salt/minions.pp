class role::salt::minions(
    $salt_master     = $::salt_master_override,
    $salt_finger     = $::salt_master_finger_override,
    $salt_master_key = $::salt_master_key,
) {
    if $::realm == 'labs' {
        $labs_master = hiera('saltmaster')

        # On older systems (e.g. jessie) use MD5 fingerprint
        if os_version('debian >= stretch') {
            $labs_finger   = 'a3:29:31:ac:79:4e:a3:9a:74:d3:c8:d6:92:08:00:50:c9:e1:b3:c8:4a:4b:03:3a:58:32:29:c6:67:4e:b5:fd'
        } else {
            $labs_finger   = 'c5:b1:35:45:3e:0a:19:70:aa:5f:3a:cf:bf:a0:61:dd'
        }
        $master        = pick($salt_master, $labs_master)
        $master_finger = pick($salt_finger, $labs_finger)

        $client_id     = $::fqdn

        class { '::salt::minion':
            id            => $client_id,
            master        => $master,
            master_finger => $master_finger,
            master_key    => $salt_master_key,
            grains        => {
                realm   => $::realm,
                site    => $::site,
                cluster => hiera('cluster', $::cluster),
            },
        }
    }
}
