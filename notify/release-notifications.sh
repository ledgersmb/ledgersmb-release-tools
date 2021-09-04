#!/bin/bash


while [[ $# -ne 0 ]]
do
    case "$1" in
        --release-type)
            release_type="$2"
            shift 2;
            ;;
        --branch)
            branch="$2"
            shift 2;
            ;;
        *)
            echo "Unknown argument $1 ignored"
            shift
            ;;
    esac
done

# import some functions that we need, like reading values from our config file.

if [[ -n "$branch" ]]
then
    rel_params=~/ledgersmb-$branch-release-parameters
else
    rel_params=~/ledgersmb-release-parameters
fi

if [[ -f $rel_params ]]
then
    source ~/ledgersmb-$branch-release-parameters
else
    echo "Missing release parameters file '$rel_params'"
fi

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

updateMatrix() {
    MATRIX_USER="${cfgValue[matrix_User]}" MATRIX_PASSWORD="${cfgValue[matrix_Password]}" MATRIX_SERVER="${cfgValue[matrix_Server]}" \
    MATRIX_ROOM="${cfgValue[matrix_Room]}}" release_version=$release_version release_type=$release_type $basedir/notification-helpers/release-matrix
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
        #updateIRC;
        updateMatrix;
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
        # while true; do
        #     TestConfigInit;
        #     TestConfig4Key 'mail'   'AnnounceList'  'announce@lists.ledgersmb.org'
        #     TestConfig4Key 'mail'   'UsersList'     'users@lists.ledgersmb.org'
        #     TestConfig4Key 'mail'   'DevelList'     'devel@lists.ledgersmb.org'
        #     TestConfig4Key 'mail'   'FromAddress'   'release@ledgersmb.org'
        #     TestConfig4Key 'mail'   'MTAbinary'     'ssmtp'
        #     if TestConfigAsk "Send List Mail"; then break; fi
        # done

        # while true; do
        #     TestConfigInit;
        #     TestConfig4Key 'wiki'   'PageToEdit'    'Wikipedia:Sandbox'
        #     TestConfig4Key 'wiki'   'User'          'foobar'
        #     TestConfig4Key 'wiki'   'Password'      ''
        #     if TestConfigAsk "Wikipedia Version Update"; then break; fi
        # done

        # while true; do
        #     TestConfigInit;
        #     TestConfig4Key 'drupal' 'URL'           'www.ledgersmb.org'
        #     TestConfig4Key 'drupal' 'User'          'foobar'
        #     TestConfig4Key 'drupal' 'Password'      ''
        #     if TestConfigAsk "ledgersmb.org Release Post"; then break; fi
        # done

        # while true; do # the script release-IRC.sh checks its own config. but lets at least make sure we have a server url
        #     TestConfigInit;
        #     TestConfig4Key 'irc' 'Server' 'chat.freenode.net';
        #     if TestConfigAsk "IRC Topic Update"; then break; fi
        # done

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

echo "
Please execute the following steps manually:

 * Update the latest version on Wikipedia
   - https://en.wikipedia.org/wiki/Comparison_of_accounting_software
   - https://ru.wikipedia.org/w/index.php?title=%D0%9F%D1%80%D0%BE%D0%B5%D0%BA%D1%82:%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D0%BE%D0%BD%D0%BD%D1%8B%D0%B5_%D1%82%D0%B5%D1%85%D0%BD%D0%BE%D0%BB%D0%BE%D0%B3%D0%B8%D0%B8/%D0%A1%D0%BF%D0%B8%D1%81%D0%BA%D0%B8/%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA_ERP-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC&action=edit

List of ERP software packages (multiple languages):
   - https://en.wikipedia.org/wiki/List_of_ERP_software_packages
   - https://ja.wikipedia.org/wiki/ERP%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2%E3%83%91%E3%83%83%E3%82%B1%E3%83%BC%E3%82%B8%E3%81%AE%E4%B8%80%E8%A6%A7
   - https://es.wikipedia.org/wiki/Anexo:Software_ERP
   - https://fr.wikipedia.org/wiki/Liste_de_progiciels_de_gestion_int%C3%A9gr%C3%A9s
"


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





