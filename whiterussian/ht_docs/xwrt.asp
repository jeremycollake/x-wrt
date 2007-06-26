<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>
      X-Wrt
    </title>
    <meta name="description" content="X-Wrt is a set of packages and patches to enhance the end user experience of OpenWrt." />
    <meta name="keywords" content="X-Wrt XWrt OpenWrt" />
    <link rel="stylesheet" type="text/css" href="style.css" />
    <script type="text/javascript">
//<![CDATA[
     function installWebif(version) {
            var install_url = "http://" + document.instform.ip.value + "/cgi-bin/webif/ipkg.sh?action=install&amp;pkg=";
            if (version=="stable") install_url += "http://ftp.berlios.de/pub/xwrt/webif_latest_stable.ipk";
            else if (version=="latest") install_url += "http://ftp.berlios.de/pub/xwrt/webif_latest.ipk";
            else return false;
            window.open(install_url, 'Installation', 'toolbar=yes,resizable=yes');
    }
    //]]>
    </script>
  </head>

  <body>
    <div id="container">
      <div id="header">
        <h1>
          <span>X</span>-Wrt
        </h1><em>OpenWrt for end users</em>
      </div>
      <hr />

      <p>
        <strong>X-Wrt</strong> is a set of packages and patches to enhance the end user experience of OpenWrt. It is NOT a fork of OpenWrt.
        We work in conjunction with the OpenWrt developers to extend OpenWrt.
      </p>
      <p>
        Our packages currently work with the latest public release of OpenWrt - White Russian RC6. We also maintain backwards compatibility
        with OpenWrt White Russian RC5. Support of OpenWrt's upcoming Kamikaze firmware is coming soon. Explore this page to learn about
        our work, or just skip straight to installing X-Wrt and see the fruits of our labor yourself.
      </p>
      <h3>
        Project links:
      </h3>

      <ul>
        <li>
          <a href="https://developer.berlios.de/projects/xwrt/">Project Hosting</a>
        </li>
        <li>
          <a href="http://xwrt.kicks-ass.org/xwrt/">FTP Site #1</a> (Firmware Images, Image Builder, SDK)
        </li>
        <li>

          <a href="ftp://ftp.berlios.de/pub/xwrt">FTP Site #2</a> (Source / Package Repository)
        </li>
        <li>
          <a href="http://www.bitsum.com/xwrt">Screenshots</a>
        </li>
        <li>
          <a href="http://xwrt.berlios.de/forum">Forums</a><sup>*</sup>

        </li>
        <li>
          <a href="http://xwrt.berlios.de/wiki/">Wiki</a><sup>*</sup>
        </li>
        <li>
          <a href="mailto:jeremy@bitsum.com">Email</a>
        </li>

        <li>
          <a href="#x-wrt">IRC</a>
        </li>
      </ul>
      <p>
        <em><sup>*</sup>SERVER TROUBLES! Our host, berlios.de, has been having persistent server problems. If the forums, wiki, or other
        project sites aren't available, please try again later. If you would like to help us with our web hosting, please contact <a href=
        "mailto:jeremy.collake@gmail.com?subject=x-wrt%20web%20hosting">me</a>.</em>

      </p>
      <h3>
        Document navigation:
      </h3>
      <ol style="list-style-type: upper-roman;">
        <li>
          <a href="#introduction">Introduction to X-Wrt</a>
        </li>
        <li>

          <a href="#installation">Installation Instructions</a>
        </li>
        <li>
          <a href="#problems">Webif&sup2; Troubleshooting</a>
        </li>
        <li>
          <a href="#packages">X-Wrt Packages</a>

        </li>
        <li>
          <a href="#roadmap">Milestone Roadmap</a>
        </li>
        <li>
          <a href="#kamikaze">OpenWrt Kamikaze Plans</a>
        </li>
        <li>

          <a href="#commercial">Commercial use: Sure!</a>
        </li>
        <li>
          <a href="#participate">Participate</a>
        </li>
        <li>
          <a href="#support">Support X-Wrt</a>

        </li>
      </ol>
      <h2 id="introduction">
        Introduction to X-Wrt
      </h2>
      <p>
        X-Wrt was started because there was a need for end user extensions to OpenWrt, such as an enhanced web management console (webif).
        For a long time now it has been established that OpenWrt is the best firmware in its class. It far exceeds other firmwares in
        performance, stability, extensibility, robustness, and design. We at X-Wrt decided it was long past time for end users to get
        access to this superior firmware.
      </p>
      <p>
        We are a separate project from OpenWrt due to the difference in focus and development ideals. We are considerably more pragmatic
        than OpenWrt and have the goal of providing solutions today, while OpenWrt has a more idealistic development philosophy and intends
        to perfect the firmware core, no matter how many rewrites and how much time it takes. This difference in development attitude
        creates a complimentary atmosphere that benefits everyone.
      </p>

      <p>
        This is a free, open-source, community-driven project. Our primary project ideals are:
      </p>
      <ul>
        <li>
          <strong>Free and open-source.</strong> The project should be entirely free and open-source, licensed under the GPL. The project
          should always be hosted at an easily accessible site and source code readily available and easily built.
        </li>
        <li>
          <strong>Easy entrance.</strong> The project should always be open to new contributors and have a low entrance barrier. Anyone
          should be able to contribute. We actively grant write access to anyone interested in having it. We believe people are responsible
          when given responsibility. Just ask and we'll sign you up.
        </li>

        <li>
          <strong>Community driven.</strong> This isn't about 'us' offering 'you' something, it's about everyone coming together to work
          towards the common goal.
        </li>
        <li>
          <strong>No monetary donations without accounting.</strong> The project can not accept monetary donations without having a
          treasurer to hold and account for all donations and what they have went towards.
        </li>
      </ul>
      <p>

        This project is still young, but we are accomplishing things at a rapid pace. All our work is currently in beta, but our code can
        be used today and is more stable than many firmwares in their 'final' state. You can keep up with the latest developments by
        checking the xwrt-svncheckins message list that archives commit logs as they happen: <a href=
        "https://lists.berlios.de/pipermail/xwrt-svncheckins">https://lists.berlios.de/pipermail/xwrt-svncheckins</a>.
      </p>
      <p>
        Our latest stable snapshot of webif&sup2; is <strong>Milestone 2.5</strong>. The install buttons below will have you install it. If
        you then use the webif's update feature you will get the latest internal build.
      </p>
      <h2 id="installation">
        Installation Instructions
      </h2>

      <p>
        X-Wrt is a set of packages that overlay OpenWrt. There are two primary ways to install and use X-Wrt on your router:
      </p>
      <ul>
        <li>Flash a pre-built image of OpenWrt White Russian with X-Wrt packages like webif&sup2; already included.
        </li>
        <li>Flash OpenWrt White Russian stock image, then install webif&sup2; and any other X-Wrt packages.
        </li>

      </ul>
      <h3>
        Method #1:
      </h3><em>Flash pre-built OpenWrt White Russian images</em>
      <ul>
        <li>Browse the X-Wrt ftp directory for the OpenWrt/X-Wrt firmware image appropriate for your router (based on the filename).
        </li>
        <li>Flash the image to your router by using either your existing firmware's web interface to upgrade the firmware or alternate
        methods. If you have questions, advanced instructions are available on OpenWrt's Wiki.
          <br />
        </li>

      </ul>
      <h4>
        Direct Firmware Links:
      </h4>
      <ul>
        <li>
          <a href="http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/">Default Firmware Images</a>
          (PPPOE included)
          <ul>

            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wrt54g-squashfs.bin">WRT54G
              v1-v4 and WRT54GL</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wrt54g3g-squashfs.bin">WRT54g3g</a>
            </li>
            <li>WRT54G v5-v6 (not yet available)
            </li>

            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wrt54gs-squashfs.bin">WRT54GS
              v1-v3</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wrt54gs_v4-squashfs.bin">WRT54GS
              v4</a>
            </li>
            <li>WRT54GS v5-v6 (not yet available)
            </li>

            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wrtsl54gs-squashfs.bin">WRTSL54GS</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-brcm-2.4-squashfs.trx">WL-500g/d/p</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-brcm-2.4-squashfs.trx">WZR-HP-54GS</a>

            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-brcm-2.4-squashfs.trx">WHR-54GS</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-we800g-squashfs.bin">WE-800G</a>
            </li>
            <li>

              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wa840g-squashfs.bin">WA-840G</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/openwrt-wr850g-squashfs.bin">WR-850G</a>
            </li>
          </ul>
        </li>
        <li>

          <a href="http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/">PPTP Firmware Images</a>
          <ul>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wrt54g-squashfs.bin">WRT54G
              v1-v4 and WRT54GL</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wrt54g3g-squashfs.bin">WRT54g3g</a>

            </li>
            <li>WRT54G v5-v6 (not yet available)
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wrt54gs-squashfs.bin">WRT54GS
              v1-v3</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wrt54gs_v4-squashfs.bin">WRT54GS
              v4</a>

            </li>
            <li>WRT54GS v5-v6 (not yet available)
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wrtsl54gs-squashfs.bin">WRTSL54GS</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-brcm-2.4-squashfs.trx">WL-500g/d/p</a>

            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-brcm-2.4-squashfs.trx">WZR-HP-54GS</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-brcm-2.4-squashfs.trx">WHR-54GS</a>
            </li>
            <li>

              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-we800g-squashfs.bin">WE-800G</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wa840g-squashfs.bin">WA-840G</a>
            </li>
            <li>
              <a href=
              "http://xwrt.kicks-ass.org/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/pptp/openwrt-wr850g-squashfs.bin">WR-850G</a>

            </li>
          </ul>
        </li>
      </ul>
      <h3>
        Method #2
      </h3><em>Flash OpenWrt White Russian then install X-Wrt packages</em>
      <p>
        If you do not already have OpenWrt White Russian on your router, download an appropriate OpenWrt White Russian image and flash it
        (follow instructions in OpenWrt's wiki). We recommend White Russian RC5, RC6, or 0.9 (when it is released). Kamikaze is NOT
        supported yet, but will be soon.
      </p><em class="warning">WARNING: Do not install webif&sup2; on the micro images OpenWrt distributes. They lack the 'ipkg' package,
      which is currently critical to the proper operation of webif&sup2;</em>

      <h4>
        Installation:
      </h4>
      <ol>
        <li>Visit your router's IP with your web browser and set the password. For example, http://192.168.1.1.
        </li>
        <li>Enter your router's IP address in the field below and click the button below to install the latest official beta release of
        X-Wrt's webif. After you install the latest official beta release the 'check for update' and 'upgrade' buttons you'll find in the
        webif itself will move you up to the latest daily build, which has more features but has been less extensively tested.
          <br />
          <br />
          <form action="" name="instform" id="instform">

            <label for="ip"><strong>Your router's IP address:</strong>
            <br /></label> <input type="text" id="ip" value="192.168.1.1" />
            <br />
            <strong>Choose version and press button to install:</strong>
            <br />
            <input type="button" value="Latest version" onclick="installWebif('latest'); return false;" /> <input type="button" value=
            "Stable version" onclick="installWebif('stable'); return false;" />
          </form>

          <br />
          You will not see much of anything for a minute. Just wait. If you see the password prompt, you skipped step 1 and need to come
          back here and click the above button again after you've set the password.
          <br />
          <br />
          <em class="warning">Be warned, the very first install of webif&sup2; will reboot your router!</em>
        </li>
      </ol>
      <p>

        If the display of the web pages looks funny, do a hard refresh (hold down SHIFT and click REFRESH) to clear out the old CSS.
      </p>
      <p>
        Instead of using this automated install procedure, you can also ssh or telnet to the router and run:
      </p>
      <ul>
        <li>(latest milestone): <code>ipkg install http://ftp.berlios.de/pub/xwrt/webif_latest_stable.ipk</code>
        </li>
        <li>(latest daily): <code>ipkg install http://ftp.berlios.de/pub/xwrt/webif_latest.ipk</code>

        </li>
      </ul>
      <h2 id="problems">
        Webif&sup2; Problems
      </h2>
      <p>
        Since our new webif is in beta sometimes you can get a build that has problems. The best advice is:
      </p>
      <ol>

        <li>Upgrade to a newer build when it is available.
        </li>
        <li>Report bugs or other errata you see if you don't find it fixed in the next build. It's hard for us to test every build
        thoroughly.
        </li>
        <li>If you somehow got unlucky and ended up with a daily build that was horribly broken and you can't upgrade the webif, ssh into
        the router and run this:
          <br />
          <code>ipkg install http://ftp.berlios.de/pub/xwrt/webif_latest.ipk -force-reinstall</code>
        </li>
      </ol>
      <h3>

        Common Problems
      </h3>
      <dl>
        <dt>
          Q: I keep getting errors with 'ipkg' on pages.
        </dt>
        <dd>
          A: X-Wrt's webif does not currently work right on the micro images OpenWrt distributes because there is no 'ipkg' package.
        </dd>
        <dt>

          Q: I am having some trouble or another with a page or really need newer features.
        </dt>
        <dd>
          A: Try upgrading to the latest daily build of the webif if you want.
        </dd>
      </dl>
      <h2 id="packages">
        X-Wrt Packages
      </h2>
      <p>

        Although all our work is based around our webif&sup2; package, we actually have a number of packages to add to OpenWrt. At present
        they are all for White Russian, but we are moving actively into Kamikaze right now. A list of some of our packages are:
      </p>
      <ul>
        <li>
          <strong>webif&sup2;</strong> - our new webif, but you already know that ;).
        </li>
        <li>
          <strong>miniupnpd</strong> - an offering of this excellent new upnp daemon.
        </li>

        <li>
          <strong>tarfs</strong> - a specialized pseudo-filesystem for micro sized routers. - alpha stage development
        </li>
        <li>
          <strong>busybox 1.2.1</strong> - an update over the Busybox 1.0 used in White Russian. It also includes some different applets,
          like user management utilities.
        </li>
        <li>
          <strong>wireless-tools v29 pre10</strong> - an update to wireless-tools (iwconfig, iwlist, etc..).
        </li>

        <li>
          <strong>ipkg-upgrade-fix</strong> - issues a warning when a user tries to run 'ipkg upgrade', something known to wreak havoc on
          unsuspecting users.
        </li>
      </ul>
      <h2 id="roadmap">
        Milestone Roadmap
      </h2>
      <p>
        <strong>Last Release:</strong> Milestone 2.5
      </p>

      <p>
        For every Milestone there are countless updates, so this is far from a comprehensive list of changes and planned changes. However,
        it does give some idea of what our development plan is.
      </p>
      <p>
        Of course, this table only shows the release we have planned in the immediate future.
      </p>
      <table summary="X-Wrt Roadmap">
        <tr>
          <th class="green">
            Milestone 1
            <br />

            Oct. 2006
          </th>
          <th class="green">
            Milestone 2
            <br />
            Nov. 2006
          </th>
          <th class="green">
            Milestone 2.5
            <br />
            Dec. 2006
          </th>

          <th class="red">
            Milestone 3
            <br />
            Jan. 2007<sup>*</sup>
          </th>
          <th class="red">
            Milestone 4
            <br />
            Feb. 2007<sup>*</sup>

          </th>
        </tr>
        <tr>
          <td>
            <ul>
              <li>First public stable build
              </li>
            </ul>
          </td>

          <td>
            <ul>
              <li>Many new pages;
              </li>
              <li>Polishing and fixes
              </li>
            </ul>
          </td>
          <td>
            <ul>

              <li>Some new pages;
              </li>
              <li>Better theme support;
              </li>
              <li>Better language support;
              </li>
              <li>Polishing and fixes
              </li>
            </ul>
          </td>
          <td>

            <ul>
              <li>SSL support;
              </li>
              <li>Remote mgt;
              </li>
              <li>New pages;
              </li>
              <li>More Polishing
              </li>
            </ul>
          </td>

          <td>
            <ul>
              <li>Kamikaze support
              </li>
            </ul>
          </td>
        </tr>
      </table><em><sup>*</sup>Future dates are estimates. The actual release may be before or after that date.</em>

      <h2 id="kamikaze">
        OpenWrt Kamikaze Plans
      </h2>
      <p>
        We are working actively towards a version of the webif for OpenWrt's long delayed next generation, Kamikaze. By the time Kamikaze
        goes public, we probably will have finished support for it.
      </p>
      <p>
        OpenWrt Kamikaze represents a substantial and fundamental change. It is not simply a new version of White Russian, but instead a
        complete rewrite of the build root and configuration structure. That is why White Russian went stagnant for so long, the developers
        quit working on it in favor of this more ambitious idealized solution. This new branch of OpenWrt took a long, long time to hash
        out, but now its almost ready.
      </p>
      <p>

        The ever-popular NVRAM configuration storage system is no longer utilized in Kamikaze. It has been replaced with configuration
        files, many stored in the common format known as 'UCI'. This was done because although an emulated NVRAM storage area to keep tuple
        based configuration data can be easily implemented on any platform, the OpenWrt developers felt it wasn't structured enough for
        their tastes. So, out the window it went.
      </p>
      <p>
        To make the webif work with Kamikaze we therefore have to work with this new configuration system. The good news is our webif
        already supports UCI. Some pages, like the QoS page, use the UCI system entirely.
      </p>
      <p>
        More and more pages utilize UCI and support kamikaze. We hope to have basic Kamikaze support by the end of 2006 and a stable image
        in the first quarter of 2007.
      </p>
      <h2 id="commercial">
        Can I use X-Wrt in my commercial venture?
      </h2>

      <p>
        Yes, you can use X-Wrt in whatever way you like, providing you do not violate the terms of the GPL license agreement. We can even
        help you to rebrand the webif and tweak it to suit your needs. <a href="mailto:jeremy@bitsum.com?subject=X-Wrt%20in%20use">Email
        us</a> to inquire about webif related contract work.
      </p>
      <h2 id="participate">
        Participate
      </h2>
      <p>
        We always need developers, testers, documentation writers, translators, and support personnel. Our project is truly OPEN and FREE.
        Anyone can come join our project.
      </p>

      <p>
        If you would like to get write access to our repository, just create an account at <a href=
        "http://www.berlios.de">www.berlios.de</a> and email <a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a> or contact one of our
        other developers on the irc channel (#x-wrt / freenode). We do not make anyone pass an 'entrance exam', though we do like for
        people to supply a patch of some sort just to prove that you are serious.
      </p>
      <p>
        A listing of some of the needs we have are:
      </p>
      <ul>

        <li>development
        </li>
        <li>graphic artists
        </li>
        <li>localization (translation)
        </li>
        <li>documentation/wiki editors
        </li>
        <li>user support
        </li>
        <li>proliferators
        </li>

      </ul>
      <h2 id="support">
        Support
      </h2>
      <p>
        There are some things you can help us with if you choose. When a person makes a donation, that donation is cataloged and made
        available to whichever developer is in the most need of it at the time. We do have a public list of donators (or at least will,
        whenever we get some donations).
      </p>
      <ul>
        <li>
          <strong>web hosting.</strong> Berlios provides most our web services, but their servers are overwhelmed and we're out of
          resources. This situation will only get worse. We need an alternate host to put things like release files, forum, and wiki on.
        </li>

        <li>
          <strong>hardware donations.</strong> You can donate routers or other hardware to our developers, who may be in need of them for
          testing purposes. We are currently running our poor routers into the ground, so we encourage these type of donations. Devices
          needed:
          <ul>
            <li>Any router with a USB port.
            </li>
            <li>Any router you want us to work on support for.
            </li>
            <li>Anything you have left lying around.
            </li>
          </ul>

        </li>
        <li>
          <strong>spread the word.</strong> Tell people you think might be interested about our project. Not even all OpenWrt users have
          heard of our project yet. You might consider mentioning X-Wrt on the OpenWrt forums and in #openwrt on freenode.
        </li>
      </ul>
      <p>
        To prevent troubles with where money should go, we don't accept project-wide monetary donations. However, some developers do accept
        direct donations to them. We suggest you check the Berlios roster of developers of this project and develop to whichever people you
        choose. Also, if you want to see a particular feature developed, perhaps donating to a developer will encourage him or her to
        pursue that feature more quickly than he or she would have otherwise done.
      </p>
    </div>

  </body>
</html>
