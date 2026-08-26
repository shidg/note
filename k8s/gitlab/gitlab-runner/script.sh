#!/bin/bash
# File Name: -- script.sh --
# author: -- shidegang --
# Created Time: 2025-07-30 17:56:30

#!/bin/bash

unknown_os ()
{
  echo "Unfortunately, your operating system distribution and version are not supported by this script."
  echo
  echo "You can override the OS detection by setting os= and dist= prior to running this script."
  echo "You can find a list of supported OSes and distributions on our website: https://packages.gitlab.com/docs#os_distro_version"
  echo
  echo "For example, to force CentOS 6: os=el dist=6 ./script.sh"
  echo
  echo "Please email support@packagecloud.io and let us know if you run into any issues."
  exit 1
}

curl_check ()
{
  echo "Checking for curl..."
  if command -v curl > /dev/null; then
    echo "Detected curl..."
  else
    echo "Installing curl..."
    yum install -d0 -e0 -y curl
  fi
}


detect_os ()
{
  if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
    if [ -e /etc/os-release ]; then
      . /etc/os-release
      os=${ID}
      if [ "${os}" = "poky" ]; then
        dist=`echo ${VERSION_ID}`
      elif [ "${os}" = "sles" ]; then
        dist=`echo ${VERSION_ID}`
      elif [ "${os}" = "opensuse" ]; then
        dist=`echo ${VERSION_ID}`
      elif [ "${os}" = "opensuse-leap" ]; then
        os=opensuse
        dist=`echo ${VERSION_ID}`
      elif [ "${os}" = "amzn" ]; then
        dist=`echo ${VERSION_ID}`
      else
        dist=`echo ${VERSION_ID} | awk -F '.' '{ print $1 }'`
      fi

    elif [ `which lsb_release 2>/dev/null` ]; then
      # get major version (e.g. '5' or '6')
      dist=`lsb_release -r | cut -f2 | awk -F '.' '{ print $1 }'`

      # get os (e.g. 'centos', 'redhatenterpriseserver', etc)
      os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`

    elif [ -e /etc/oracle-release ]; then
      dist=`cut -f5 --delimiter=' ' /etc/oracle-release | awk -F '.' '{ print $1 }'`
      os='ol'

    elif [ -e /etc/fedora-release ]; then
      dist=`cut -f3 --delimiter=' ' /etc/fedora-release`
      os='fedora'

    elif [ -e /etc/redhat-release ]; then
      os_hint=`cat /etc/redhat-release  | awk '{ print tolower($1) }'`
      if [ "${os_hint}" = "centos" ]; then
        dist=`cat /etc/redhat-release | awk '{ print $3 }' | awk -F '.' '{ print $1 }'`
        os='centos'
      elif [ "${os_hint}" = "scientific" ]; then
        dist=`cat /etc/redhat-release | awk '{ print $4 }' | awk -F '.' '{ print $1 }'`
        os='scientific'
      else
        dist=`cat /etc/redhat-release  | awk '{ print tolower($7) }' | cut -f1 --delimiter='.'`
        os='redhatenterpriseserver'
      fi

    else
      aws=`grep -q Amazon /etc/issue`
      if [ "$?" = "0" ]; then
        dist='6'
        os='aws'
      else
        unknown_os
      fi
    fi
  fi

  if [[ ( -z "${os}" ) || ( -z "${dist}" ) ]]; then
    unknown_os
  fi

  # Enumerate all old versions that need pygpgme for each os/dist.
  # This is not hard because all old versions are known.
  # Even if we miss some versions, users will report them and eventually we'll have a complete list.
  # This ensures that if pygpgme is required, we will install it.
  # The harder part is detecting when pygpgme is NOT required since we don't know what
  # new version names/numbering are, however, it's alright to miss those because
  # as long as they are not the enumerated old versions, we can assume that they are new.
  # If we wrongly assume that they are new, then repo/package install will fail and users
  # will report back, and this goes away eventually once we have a complete list of old versions
  amzn_dist_requires_pygpgme_array=("1${IFS}2${IFS}2016${IFS}2017${IFS}2018")

  echo "Detected operating system as ${os}/${dist}."

  if [[ "$os" = "ol" || "$os" = "el" || "$os" = "rocky" || "$os" = "almalinux" || "$os" = "centos" || "$os" = "rhel" ]] && [ $(($dist)) \> 7 ]; then
    _skip_pygpgme=1
  elif [ "$os" = "fedora" ] && [ $(($dist)) \> 19 ]; then
    _skip_pygpgme=1
  elif [ "$os" = "amzn" ]; then
    amzn_dist="${dist%%[.-]*}"
    if  [[ ! " ${amzn_dist_requires_pygpgme_array[*]} " =~ [[:space:]]${amzn_dist}[[:space:]] ]]; then
      # whatever you want to do when array doesn't contain value
      _skip_pygpgme=1
    else
      _skip_pygpgme=0
    fi
  else
    _skip_pygpgme=0
  fi
}

finalize_yum_repo ()
{
  if [ "$_skip_pygpgme" = 0 ]; then
    echo "Attempting to install pygpgme for your os/dist: ${os}/${dist}. Only required on older OSes to verify GPG signatures."
    yum install -y pygpgme --disablerepo="runner_gitlab-runner" 2>/dev/null
    pypgpme_check=`rpm -qa | grep -qw pygpgme`
    if [ "$?" != "0" ]; then
      echo
      echo "Note: "
      echo "The pygpgme package may no longer be required for your OS (${os}/${dist}), and has not been installed."
      echo "If your repo and package installation does not work please reach out to support."
      echo
    fi
  fi

  echo "Installing yum-utils..."
  yum install -y yum-utils --disablerepo='runner_gitlab-runner'
  yum_utils_check=`rpm -qa | grep -qw yum-utils`
  if [ "$?" != "0" ]; then
    echo
    echo "WARNING: "
    echo "The yum-utils package could not be installed. This means you may not be able to install source RPMs or use other yum features."
    echo
  fi

  echo "Generating yum cache for runner_gitlab-runner..."
  yum -q makecache -y --disablerepo='*' --enablerepo='runner_gitlab-runner'

  echo "Generating yum cache for runner_gitlab-runner-source..."
  yum -q makecache -y --disablerepo='*' --enablerepo='runner_gitlab-runner-source'
}

finalize_zypper_repo ()
{
  zypper --gpg-auto-import-keys refresh runner_gitlab-runner
  zypper --gpg-auto-import-keys refresh runner_gitlab-runner-source
}

main ()
{
  detect_os
  curl_check


  yum_repo_config_url="https://packages.gitlab.com/install/repositories/runner/gitlab-runner/config_file.repo?os=${os}&dist=${dist}&source=script"

  if [ "${os}" = "sles" ] || [ "${os}" = "opensuse" ]; then
    yum_repo_path=/etc/zypp/repos.d/runner_gitlab-runner.repo
  else
    yum_repo_path=/etc/yum.repos.d/runner_gitlab-runner.repo
  fi

  echo "Downloading repository file: ${yum_repo_config_url}"

  curl -sSf "${yum_repo_config_url}" > $yum_repo_path
  curl_exit_code=$?

  if [ "$curl_exit_code" = "22" ]; then
    echo
    echo
    echo -n "Unable to download repo config from: "
    echo "${yum_repo_config_url}"
    echo
    echo "This usually happens if your operating system is not supported by "
    echo "packagecloud.io, or this script's OS detection failed."
    echo
    echo "You can override the OS detection by setting os= and dist= prior to running this script."
    echo "You can find a list of supported OSes and distributions on our website: https://packages.gitlab.com/docs#os_distro_version"
    echo
    echo "For example, to force CentOS 6: os=el dist=6 ./script.sh"
    echo
    echo "If you are running a supported OS, please email support@packagecloud.io and report this."
    [ -e $yum_repo_path ] && rm $yum_repo_path
    exit 1
  elif [ "$curl_exit_code" = "35" -o "$curl_exit_code" = "60" ]; then
    echo
    echo "curl is unable to connect to packagecloud.io over TLS when running: "
    echo "    curl ${yum_repo_config_url}"
    echo
    echo "This is usually due to one of two things:"
    echo
    echo " 1.) Missing CA root certificates (make sure the ca-certificates package is installed)"
    echo " 2.) An old version of libssl. Try upgrading libssl on your system to a more recent version"
    echo
    echo "Contact support@packagecloud.io with information about your system for help."
    [ -e $yum_repo_path ] && rm $yum_repo_path
    exit 1
  elif [ "$curl_exit_code" -gt "0" ]; then
    echo
    echo "Unable to run: "
    echo "    curl ${yum_repo_config_url}"
    echo
    echo "Double check your curl installation and try again."
    [ -e $yum_repo_path ] && rm $yum_repo_path
    exit 1
  else
    echo "done."
  fi

  if [ "${os}" = "sles" ] || [ "${os}" = "opensuse" ]; then
    finalize_zypper_repo
  else
    finalize_yum_repo
  fi

  echo
  echo "The repository is setup! You can now install packages."
}

main

