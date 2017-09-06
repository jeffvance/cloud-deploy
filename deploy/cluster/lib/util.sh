#! /bin/bash

# Generate a 4 character string to be used as a suffix for
# GCP resources.
# Returns: Array of stings.
# Args:
#	1 - int, number of unique suffixes required.
function util::unique_id_arr {
	local num_ids=${1:-"4"}
	UUIDS="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n $num_ids)"
}

# pre-start-check looks for existing resources that may have been orphaned
# from a prior run.
# args:
#   prefix($1): expected name prefix (usually $GCP_USER)
# returns GLOBALS:
#	O_INSTANCES		list of instance names				e.g. "inst1 inst2 inst3"
#	O_GROUPS		list of instance group names		''			''	
#	O_TEMPLATES		list of	instance template names		''			''
#	O_DISKS			list of disk names					''			''
function util::check-orphaned-resources {
	local instances=$(gcloud compute instances list --regexp="$GCP_USER".* 2>/dev/null)
	local instgroups=$(gcloud compute instance-groups list --regexp="$GCP_USER".* 2>/dev/null)
	local templates=$(gcloud compute instance-templates list --regexp="$GCP_USER".* 2>/dev/null)
	local disks=$(gcloud compute disks list --regexp="$GCP_USER".* 2>/dev/null)
	if [[ -n "$instances" ]]; then
		printf "\n========Found Instances========\n%s\n" "$instances"
		INSTANCES_LIST=$(echo "$instances" | awk 'NR>1{print $1}')
	fi
	if [[ -n "$instgroups" ]]; then
		printf "\n========Found Instance Groups========\n%s\n" "$instgroups"
		GROUPS_LIST=$(echo "$instgroups" | awk 'NR>1{print $1}')
	fi
	if [[ -n "$templates" ]]; then
		printf "\n========Found Instance Templates========\n%s\n" "$templates"
		TEMPLATES_LIST=$(echo "$templates" | awk 'NR>1{print $1}')
	fi
	if [[ -n "$disks" ]]; then
		printf "\n========Found Disks========\n%s\n" "$disks"
		DISKS_LIST=$(echo "$disks" | awk 'NR>1{print $1}')
	fi
}

function util::do-cleanup {
	if [[ -n "${GROUPS_LIST:-}"  ]]; then
		if ! gcloud compute instance-groups managed delete "${GROUPS_LIST:-}" --quiet ; then
			echo "Failed to clean up all instance groups. Remaining:"
			gcloud compute instance-groups managed list --regexp="$GCP_USER".*
		fi
	fi
	if [[ -n "${INSTANCES_LIST:-}" ]]; then
		if ! gcloud compute instances delete ${INSTANCES_LIST:-} --quiet ; then
			echo "Failed to clean up all instances. Remaining:"
			gcloud compute instances list --regexp="$GCP_USER".*
		fi
	fi
	if [[ -n "${TEMPLATES_LIST:-}" ]]; then
		if ! gcloud compute instance-templates delete "${TEMPLATES_LIST:-}" --quiet ; then
			echo "Failed to clean up all instances. Remaining:"
			gcloud compute instance-templates list --regexp="$GCP_USER".*
		fi
	fi
	if [[ -n "${DISKS_LIST:-}" ]]; then
		if ! gcloud compute disks delete  "${DISKS_LIST:-}" --quiet ; then
			echo "Failed to clean up all instances. Remaining:"
			gcloud compute disks list --regexp="$GCP_USER".*
		fi
	fi
}

# Args:
#	$1) cmd to exec
#	$2) Max Retries
function util::exec_with_retry {
	local cmd=$1
	local max_retry=$2
	local time_limite=300 # seconds
}



