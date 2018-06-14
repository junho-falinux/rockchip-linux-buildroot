#!/bin/sh

LOCAL_DIR=$(pwd)
BUILDROOT_DIR=$LOCAL_DIR/buildroot
BUILD_OUTPUT_DIR=$LOCAL_DIR/buildroot/output

DEFCONFIG_ARRAY=( "rockchip_rk3308_release" "rockchip_rk3308_32_release" "rockchip_rk3308_robot_release" "rockchip_rk3308_mini_release" "rockchip_rk3308_pcba" "rockchip_rk3308_recovery" "rockchip_rk3326" "rockchip_rk3326_nano" "rockchip_rk3326_tiny" "rockchip_rk3326_mini" "rockchip_rk3326_medium" "rockchip_rk3326_nano_recovery" "rockchip_rk3326_medium_pcba" "rockchip_rk3399" "rockchip_rk3399_recovery" "rockchip_rk3288" "rockchip_rk3288_recovery" "rockchip_px3se" "rockchip_px3se_recovery" "rockchip_rk3328" "rockchip_rk3328_recovery")

DEFCONFIG_ARRAY_LEN=${#DEFCONFIG_ARRAY[@]}

i=0
while [[ $i -lt $DEFCONFIG_ARRAY_LEN ]]
do
	let i++
done

# Set croot alias
alias croot="cd $(pwd)"

function choose_info()
{
	echo
	echo "You're building on Linux"
	echo "Lunch menu...pick a combo:"
	echo "rockchip_ChipName_nano_defconfig:          no app, QT, video, GPU, audo, bt/wifi. only busybox"
	echo "rockchip_ChipName_tiny_defconfig:          no app, QT, video, GPU, have audo, bt/wifi, busybox."
	echo "rockchip_ChipName_mini_defconfig:          no app, QT, video, have GPU, audo, bt/wifi, busybox."
	echo "rockchip_ChipName_small_defconfig:         no app, QT, GPU, have video, audo, bt/wifi, busybox."
	echo "rockchip_ChipName_medium_defconfig:        no app, QT, have video GPU, audo, bt/wifi, busybox."
	echo "rockchip_ChipName_defconfig:               have app, QT, have video GPU, audo, bt/wifi, busybox."
	echo "rockchip_ChipName_nano_recovery_defconfig: add recovery tool base on rockchip_ChipName_nano_defconfig"
	echo "rockchip_ChipName_medium_pcba_defconfig:   add pcba test tool base on rockchip_ChipName_medium_pcba_defconfig"
	echo ""
	i=0
	while [[ $i -lt $DEFCONFIG_ARRAY_LEN ]]
	do
		if [ $i -lt 100 ]; then
			echo "$((${i}+1)). ${DEFCONFIG_ARRAY[$i]}"
		else
			echo "$((${i}+1)). ${DEFCONFIG_ARRAY[$i]}_release"
		fi
		let i++
	done
	echo
}

function get_index() {
	if [ $# -eq 0 ]; then
		return 0
	fi

	i=0
	while [[ $i -lt $DEFCONFIG_ARRAY_LEN ]]
	do
		if [ $1 = "${DEFCONFIG_ARRAY[$i]}_release" ]; then
			let i++
			return ${i}
		fi
		let i++
	done
	return 0
}

function get_target_board_type() {
	TARGET=$1
	RESULT="$(echo $TARGET | cut -d '_' -f 2)"
	echo "$RESULT"
}

function get_build_config() {
	TARGET=$1
	RESULT1="$(echo $TARGET | cut -d '_' -f 3)"
	RESULT2="$(echo $TARGET | cut -d '_' -f 4)"
	if [[ $RESULT1 = "debug" ]]; then
		echo "${DEFCONFIG_ARRAY[$index]}"
	elif [[ $RESULT1 = "release" ]]; then
		echo "${DEFCONFIG_ARRAY[$index]}"
	elif [[ $RESULT2 = "debug" ]]; then
		echo "${DEFCONFIG_ARRAY[$index]}"
	elif [[ $RESULT2 = "release" ]]; then
		echo "${DEFCONFIG_ARRAY[$index]}"
	else
		echo "${DEFCONFIG_ARRAY[$index]}"
	fi
}

function get_defconfig_name() {
	echo $TARGET_DIR_NAME
}

function get_target_build_type() {
	TARGET=$1
	TYPE="$(echo $TARGET | cut -d '_' -f 1)"

	LENGTH="$(echo $TARGET | awk -F '_' '{print NF}')"
	if [ $LENGTH -le 2 ]; then
		echo "64"
	else
		RESULT="$(echo $TARGET | cut -d '_' -f 3)"
		if [ $RESULT = "32" ]; then
			echo "32"
		elif [ $RESULT = "64" ]; then
			echo "64"
		else
			echo "64"
		fi
	fi
}

function choose_type()
{
	choose_info
	local DEFAULT_NUM DEFAULT_VALUE
	DEFAULT_NUM=1
	DEFAULT_VALUE="rockchip_rk3308_release"

	export TARGET_BUILD_TYPE=
	local ANSWER
	while [ -z $TARGET_BUILD_TYPE ]
	do
		echo -n "Which would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le $DEFCONFIG_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				TARGET_BUILD_CONFIG=`get_build_config ${DEFCONFIG_ARRAY[$index]}`
				TARGET_DIR_NAME="${DEFCONFIG_ARRAY[$index]}"
				TARGET_BUILD_TYPE=`get_target_build_type ${DEFCONFIG_ARRAY[$index]}`
				TARGET_BOARD_TYPE=`get_target_board_type ${DEFCONFIG_ARRAY[$index]}`
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo $ANSWER
			TARGET_BUILD_CONFIG="$ANSWER"
			TARGET_DIR_NAME="$ANSWER"
			TARGET_BUILD_TYPE=`get_target_build_type $ANSWER`
			TARGET_BOARD_TYPE=`get_target_board_type $ANSWER`
		fi
		if [ -n "$1" ]; then
			break
		fi
	done
	export TARGET_OUTPUT_DIR="$BUILD_OUTPUT_DIR/$TARGET_DIR_NAME"
}

function lunch()
{
	mkdir -p $TARGET_OUTPUT_DIR
	if [ -n "$TARGET_BUILD_CONFIG" ]; then
		cd buildroot
		echo "==========================================="
		echo
		echo "#TARGET_BOARD=${TARGET_BOARD_TYPE}"
		echo "#BUILD_TYPE=${TARGET_BUILD_TYPE}"
		echo "#OUTPUT_DIR=output/$TARGET_DIR_NAME"
		echo "#CONFIG=${TARGET_BUILD_CONFIG}_defconfig"
		echo
		echo "==========================================="
		make O="$TARGET_OUTPUT_DIR" "$TARGET_BUILD_CONFIG"_defconfig
	fi
	cd $LOCAL_DIR
}
function function_stuff()
{
	choose_type $@
	lunch
}

function_stuff $@