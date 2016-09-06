=======================================================================
  Willkommen bei GNUU-User - dem Operating System von GNUU e.V. 
                                        powered by Puppet
  
  Mit diesem Module werden alle Softwarekomponenten fuer den Betrieb
  eines UUCP Nodes installiert und konfiguriert: Taylor-UUCP, BSMTP, 
  postfix + inn.
  Mit dem eingerichten Testuser kann sofort eine Verbindung zu 
  uucp.gnuu.de hergestellt werden. Anmeldung und weitere Informationen
  auf http://www.gnuu.de  - Viel Spass beim Testen wuenscht GNUU e.V.

=======================================================================

  Konfiguration  : /etc/uucp, /etc/news, /etc/postfix
  Datenaustausch : uucico -s uucp.gnuu.de
  Mails batchen  : batcher g-rgsmtp uucp.gnuu.de
  News batchen   : su  news -c "send-uucp"'

  Site konfigurieren: http://www.gnuu.de/cgi-bin/login.cgi

=======================================================================


Usage:

    class {'gnuuuser':
      site     => '6913306960778',
      password => 'xxxxxx',
    }



