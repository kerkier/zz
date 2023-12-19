#!/bin/bash

#获取工作路径
CURRENT_DIR=$(
	cd $(dirname $0)
	pwd
)
#读取token
token=$(cat $CURRENT_DIR/bb.json)
#设置默认Headers参数
Header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.54 Safari/537.36"
Rererer=https://www.aliyundrive.com/
#刷新token并获取drive_id、access_token
response=$(curl https://auth.aliyundrive.com/v2/account/token -X POST -H "User-Agent:$Header" -H "Content-Type:application/json" -H "Rererer:$Rererer" -d '{"refresh_token":"'$token'", "grant_type": "refresh_token"}')
drive_id=$(echo "$response" | sed -n 's/.*"default_drive_id":"\([^"]*\).*/\1/p')
new_token=$(echo "$response" | sed -n 's/.*"refresh_token":"\([^"]*\).*/\1/p')
access_token=$(echo "$response" | sed -n 's/.*"access_token":"\([^"]*\).*/\1/p')
if [ -z "$new_token" ]; then
	echo "刷新Token失败"
	exit 1
fi
echo -n ${new_token} >$CURRENT_DIR/bb.json
echo -n "{
'token':'${new_token}',
'open_token':'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlOTE0YWYwNzBmZDg0N2Q5ODZlZTRiYmE5MGY5ZDM1MCIsImF1ZCI6IjczZTYxMTgzMWE3YzRkODdhYzQ5Yzg0ODFiZjlmMmM0IiwiZXhwIjoxNzEwNzc3NTY1LCJpYXQiOjE3MDMwMDE1NjUsImp0aSI6IjUwNWViMjkzMzAwYjRlYmE4NGJlMmZjNzBmMzM2NDQ5In0.TIwpBz5YQ7APg0r07w9favUR6ize2cHGFIcdxk5KQHnDZetcfoUmV2xd5liq4RKGJ7_doYRKV9yvPMNPRR9iXQ',
'thread_limit':32,
'is_vip':true,
'vip_thread_limit':0,
'vod_flags':'4kz|4k|auto',
'quark_thread_limit':32,
'quark_is_vip':false,
'quark_vip_thread_limit':16,
'quark_flags':'4kz|auto',
'uc_thread_limit':0,
'uc_is_vip':false,
'uc_vip_thread_limit':0,
'uc_flags':'4kz|auto',
'thunder_thread_limit':0,
'thunder_is_vip':false,
'thunder_vip_thread_limit':0,
'thunder_flags':'4k|4kz|auto',
'aliproxy':'',
'proxy':'',
'open_api_url':'https://aliyundrive-oauth.messense.me/oauth/access_token',
'danmu':true,
'quark_danmu':true,
'quark_cookie':'__pus=94f8040955a91d7f805b96d482fe1a98AARsgP5rhPs5muEJHwphulmxYZL+Ci81Q9u1Jy0nNJyIhY3Gbd54XByI+UO/k9FJmieFhDSDGnnb/9AnKJBCQA7+',
'uc_cookie':'__pus=5d97726d369b78bfb20bacdff42f8697AATsNBRgW4a6Qu227UH/ZI9SYfsrkpNJCdzRe3x4/hXu+cL8M30SwHoDNvRE0ZQp84y0/2I295+0ZZ7ksRt2sweB;__puus=7dfa559672bf66a840a9e931ef7e765bAAQDy6Q2bpV/Fd8NRo28Pkwn4kGiPYZpf2PG9hYxLu00JDPalyXtDW/BeOTmtFPnObbWBw89pvbsduSJLqclqgi6Fr9VD86bc9P9iOhWDthSCW1xaOW8uZPbzGAYy2lUSjhwGTkSHqKTDfKTyIZ4r2qlEA/VD1hmq0K6SeuL+d3GGCuqL0jTD9VblfaYVquFTbQ=',
'thunder_username':'+8619370213753',
'thunder_password':'aa123456',
'thunder_captchatoken':'ck0.7_zuAMWiHQ49calRO4nfYcvCDOqHRsSvfc8769ovT5QJ5tpJi-QsfFj3YHIZ4KHTz13hw2KAOKstJGZjRFkg0iN-nJ9heEs9eEm8AaqBsz9n4yZi2qTaAWnfuZDebb2HvRmeRYVwCaxTSvRRvY6yHh3l2ykruMK1G6OdT2e7Mli5AbRLdAnEwZ4caVOoZtpPL9pVQ9LSjXD1KgNCmbBxltwnTXPVHNPW-aECrtXs0UKmcMmdtyqNRxejz722iyGjIeAxLelcl2a7sJ4zOG5jFNiYWl56fk0zgefC5w71Ermv6DLgilqw1Dmv0GuzyLU6B1B7Z7Y5NAucX3SGIqdahFdenrVsKy8fb_QyD-6GUxUFKnt09QBJTd9A8ksJ7VcW7kOhjNYJx8QQHv09NuBj2UqGLbyr6DrUeixb-SmZPrc'
}
">$CURRENT_DIR/aa.json

#签到
response=$(curl "https://member.aliyundrive.com/v1/activity/sign_in_list" -X POST -H "User-Agent:$Header" -H "Content-Type:application/json" -H "Authorization:Bearer $access_token" -d '{"grant_type":"refresh_token", "refresh_token":"'$new_token'"}')
success=$(echo $response | cut -f1 -d, | cut -f2 -d:)
if [ $success = "true" ]; then
	echo "阿里签到成功"
fi
signday=$(echo "$response" | grep -o '"day":[0-9]\+' | cut -d':' -f2-)
status=$(echo "$response" | grep -o "\"status\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"')
isReward=$(echo "$response" | grep -o '"isReward":[^,}]\+' | cut -d':' -f2- | sed '1d')
col=1
for day in $signday; do
	stat=$(echo $status | awk -v col="$col" '{print $col}')
	reward=$(echo $isReward | awk -v col="$col" '{print $col}')
	if [ $stat = "normal" ] && [ "$reward" = "false" ]; then
		echo "正在领取第$day天奖励"
		curl -s -H "User-Agent:$Header" -H "Authorization:Bearer $access_token" -H "Content-Type: application/json" -X POST -d '{"refresh_token":"'$token'", "grant_type": "refresh_token", "signInDay": "'$day'"}' "https://member.aliyundrive.com/v1/activity/sign_in_reward"
	fi
	col=$((col + 1))
done



#删除文件
delete_File() {
	response=$(curl https://user.aliyundrive.com/v2/user/get -X POST -H "User-Agent:$Header" -H "Content-Type:application/json" -H "Rererer:$Rererer" -H "Authorization:Bearer $access_token")
	drive_id=$(echo "$response" | sed -n 's/.*"resource_drive_id":"\([^"]*\).*/\1/p')
	response=$(curl -s -H "User-Agent:$Header" -H "Authorization:Bearer $access_token" -H "Content-Type: application/json" -H "Rererer:$Rererer" -X POST -d '{"drive_id": "'$drive_id'","parent_file_id": "root"}' "https://api.aliyundrive.com/adrive/v3/file/list")
	if [ -z "$(echo "$response" | grep "items")" ]; then
		echo "获取文件列表失败"
		exit 1
	fi
	file_lines=$(echo "$response" | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"')
	type_lines=$(echo "$response" | grep -o "\"type\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"')
	col=1
	for file_id in $file_lines; do
		type=$(echo $type_lines | awk -v col="$col" '{print $col}')
		if [ $type = "file" ]; then
			curl -s -H "User-Agent:$Header" -H "Authorization:Bearer $access_token" -H "Content-Type: application/json" -X POST -d '{"requests": [{"body": {"drive_id": "'$drive_id'", "file_id": "'$file_id'"}, "headers": {"Content-Type": "application/json"}, "id": "'$file_id'", "method": "POST", "url": "/file/delete"}], "resource": "file"}' "https://api.aliyundrive.com/v3/batch"
		fi
		col=$((col + 1))
	done
}

INPUT=$1
case $INPUT in
delete_File) delete_File ;;
esac

