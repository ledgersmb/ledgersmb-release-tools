#!/bin/bash

# import some functions that we need, like reading values from our config file.

[[ -f ~/ledgersmb-release-parameters ]] \
   && source ~/ledgersmb-release-parameters


export release_version release_type release_date release_branch
export release_changelog release_sha256sums

ConfigFile=~/.lsmb-release
read -rst1 basedir < <(dirname $(readlink -f $0))

libFile=$basedir/../lib/bash-functions.sh
[[ -f $libFile ]] && { [[ -r $libFile ]] && source $libFile; } || {
    printf "\n\n\n";
    printf "=====================================================================\n";
    printf "=====================================================================\n";
    printf "====  Essential Library not readable:                            ====\n";
    printf "====        %-51s  ====\n" $libFile;
    printf "=====================================================================\n";
    printf "=====================================================================\n";
    printf "Exiting Now....\n\n\n";
    exit 1;
}

getChangelogEntry() {
    :
}

updateWikipedia() { # $1 = New Version     $2 = New Date
    # wikipedia-update.pl [boilerplate|Wikipage] [stable|preview] [NewVersion] [NewDate] [UserName Password]
    $basedir/notification-helpers/release-wikipedia.pl "${cfgValue[wiki_PageToEdit]}" \
              "$release_type" "$1" "$2" "${cfgValue[wiki_User]}" "${cfgValue[wiki_Password]}"
}

updateIRC() {
    $basedir/notification-helpers/release-irc.sh $release_type $release_version
}

composeReleaseStatement() {

    cat >~/ledgersmb-release-text <<-EOF
	The LedgerSMB development team is happy to announce yet another new
	version of its open source ERP and accounting application.
	This release contains the following fixes and improvements:

	$release_changelog


	For installation instructions and system requirements, see
	   https://github.com/ledgersmb/LedgerSMB/blob/$release_version/README.md

	The release can be downloaded from our download site at
	   https://download.ledgersmb.org/f/Releases/$release_version

	The release can be downloaded from GitHub at
	   https://github.com/ledgersmb/LedgerSMB/releases/tag/$release_version

	Or pulled from Docker Hub using the command
	   $ docker pull ledgersmb/ledgersmb:$release_version

	These are the sha256 checksums of the uploaded files:

	$release_sha256sums

EOF

    ${EDITOR:-nano} ~/ledgersmb-release-text
}

updateGitHub() {
    $basedir/notification-helpers/release-github $release_version
}

updateSite() {
    $basedir/notification-helpers/release-site $release_version $release_branch
}

sendEmail() {
    $basedir/notification-helpers/release-email.sh;
}

RunAllUpdates() {
    if ! [[ "$release_type" == "oldstable" ]]; then
        #updateWikipedia "$release_version" "$release_date";
        updateIRC;
    fi
    composeReleaseStatement;
    updateGitHub;
    updateSite;
    sendEmail;
}


ValidateEnvironment() {
    ############
    #  Select an editor. (function is in bash-functions.sh)
    ############
        SelectEditor;

    ############
    #  Test Config to make sure we have everything we need
    ############
        while true; do
            TestConfigInit;
            TestConfig4Key 'mail'   'AnnounceList'  'announce@lists.ledgersmb.org'
            TestConfig4Key 'mail'   'UsersList'     'users@lists.ledgersmb.org'
            TestConfig4Key 'mail'   'DevelList'     'devel@lists.ledgersmb.org'
            TestConfig4Key 'mail'   'FromAddress'   'release@ledgersmb.org'
            TestConfig4Key 'mail'   'MTAbinary'     'ssmtp'
            if TestConfigAsk "Send List Mail"; then break; fi
        done

        while true; do
            TestConfigInit;
            TestConfig4Key 'wiki'   'PageToEdit'    'Wikipedia:Sandbox'
            TestConfig4Key 'wiki'   'User'          'foobar'
            TestConfig4Key 'wiki'   'Password'      ''
            if TestConfigAsk "Wikipedia Version Update"; then break; fi
        done

        while true; do
            TestConfigInit;
            TestConfig4Key 'drupal' 'URL'           'www.ledgersmb.org'
            TestConfig4Key 'drupal' 'User'          'foobar'
            TestConfig4Key 'drupal' 'Password'      ''
            if TestConfigAsk "ledgersmb.org Release Post"; then break; fi
        done

        while true; do # the script release-IRC.sh checks its own config. but lets at least make sure we have a server url
            TestConfigInit;
            TestConfig4Key 'irc' 'Server' 'chat.freenode.net';
            if TestConfigAsk "IRC Topic Update"; then break; fi
        done

    ############
    #  Test Environment to make sure we have everything we need
    ############
        local _envGOOD=true;
        [[ -z $release_version ]] && { _envGOOD=false; echo "release_version is unavailable"; }
        [[ -z $release_date    ]] && { _envGOOD=false; echo "release_date is unavailable"; }
        [[ -z $release_type    ]] && { _envGOOD=false; echo "release_type is unavailable"; } # one of stable | preview
        [[ -z $release_branch  ]] && { _envGOOD=false; echo "release_branch is unavailable"; } # describes the ????
        [[ -z $release_changelog  ]] && { _envGOOD=false; echo "release_changelog is unavailable"; }
        [[ -z $release_sha256sums ]] && { _envGOOD=false; echo "release_sha256sums is unavailable"; }
        $_envGOOD || exit 1;
}


main() {
    clear;
        cat <<-EOF
	     ___________________________________________________________
	    /__________________________________________________________/|
	    |                                                         | |
	    |  Ready to send some updates out to the world            | |
	    |                                                         | |
	    |   *  Update Version on Wikipedia (en)                   | |
	    |   *  Update IRC Title                                   | |
	    |   *  Send Release Emails to                             | |
	    |           *  $(printf "%-43s" "${cfgValue[mail_AnnounceList]}";)| |
	    |           *  $(printf "%-43s" "${cfgValue[mail_UsersList]}";)| |
	    |           *  $(printf "%-43s" "${cfgValue[mail_DevelList]}";)| |
	    |                                                         | |
	    |   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    | |
	    |      The following are not yet complete                 | |
	    |                                                         | |
	    |   *  Post to $(printf "%-43s" "${cfgValue[drupal_URL]}";)| |
	    |      Don't forget to use the 'release'                  | |
	    |      content type, and set the correct branch           | |
	    |      to $( printf "%-46s" "${release_branch:-*** Need to add this info ***}";)  | |
	    |        http://ledgersmb.org/node/add/release            | |
	    |                                                         | |
	    |   * Publish a release on GitHub                         | |
	    |         by converting the tag                           | |
	    |                                                         | |
	    |_________________________________________________________|/
	
	
	EOF

    ValidateEnvironment;

    GetKey 'Yn' "Continue and send Updates to the world";
    if TestKey "Y"; then RunAllUpdates $Version $Date; fi

    echo
    echo
}


main;

exit;


#### everything below here is just notes. it can be removed without problems
+++++++++++++++++++++++++++++++++++
++++        cfgValue[@]        ++++
+++++++++++++++++++++++++++++++++++
key: drupal_Password     = 
key: drupal_URL          = www.ledgersmb.org
key: drupal_User         = *****
key: mail_FromAddress    = *******@******
key: mail_AnnounceList   = announce@lists.ledgersmb.org
key: mail_UsersList      = users@lists.ledgersmb.org
key: mail_DevelList      = devel@lists.ledgersmb.org
key: mail_Password       = testPW
key: wiki_PageToEdit     = User:Sbts.david/sandbox
key: wiki_Password       =
key: wiki_User           = ledgersmb_bot
+++++++++++++++++++++++++++++++++++





