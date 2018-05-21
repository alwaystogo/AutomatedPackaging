#使用方法

#当前工程绝对路径
project_path=$(cd `dirname $0`; pwd)
#生成的IPA文件存放路径
project_path_pre=~/Desktop/IPAFiles
#project_path_pre=../${project_path} //当前工程上一级目录

#工程名 将XXX替换成自己的工程名
project_name=XXX

#scheme名 将XXX替换成自己的sheme名
scheme_name=XXX

#打包模式 Debug/Release
development_mode=Debug

#plist文件所在路径
exportOptionsPlistPath=${project_path}/exportTest.plist

#编译过程中产生的临时文件夹，build文件夹路径(等打包成功之后删除掉)
tempBuild_path=${project_path}/build

#build文件夹路径
build_path=${project_path_pre}/build

#导出.ipa文件所在路径
exportIpaPath=${project_path_pre}/IPADir/${development_mode}


echo "Place enter the number you want to export ? [ 1:app-store 2:development] "

##
read number
while([[ $number != 1 ]] && [[ $number != 2 ]])
do
echo "Error! Should enter 1 or 2"
echo "Place enter the number you want to export ? [ 1:app-store 2:development] "
read number
done

if [ $number == 1 ];then
development_mode=Release
exportOptionsPlistPath=${project_path}/exportAppstore.plist
else
development_mode=Release
exportOptionsPlistPath=${project_path}/exportTest.plist
fi


echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit


echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit

echo '///--------'
echo '/// 编译完成'
echo '///--------'
echo ''

echo '///----------'
echo '/// 开始ipa打包'
echo '///----------'
xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ]; then
echo '///----------'
echo '/// ipa包已导出'
echo '///----------'
open $exportIpaPath
rm -r $tempBuild_path
else
echo '///-------------'
echo '/// ipa包导出失败 '
echo '///-------------'
fi
echo '///------------'
echo '/// 打包ipa完成  '
echo '///-----------='
echo ''

echo '///-------------'
echo '/// 开始发布ipa包 '
echo '///-------------'

if [ $number == 1 ];then

#验证并上传到App Store
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
"$altoolPath" --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -u XXX -p XXX -t ios --output-format xml
"$altoolPath" --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -u  XXX -p XXX -t ios --output-format xml
else

#上传到Fir
#echo "+++++上传到Fir平台+++++"
# 将XXX替换成自己的Fir平台的token
#fir login -T XXX
#fir publish $exportIpaPath/$scheme_name.ipa


#上传到蒲公英
#将XXX替换成自己蒲公英上的User Key
uKey="XXX"
#将XXX替换成自己蒲公英上的API Key
apiKey="XXX"
#执行上传至蒲公英的命令
echo "+++++上传到蒲公英平台+++++"
curl -F "file=@${exportIpaPath}/${scheme_name}.ipa" -F "uKey=${uKey}" -F "_api_key=${apiKey}" http://www.pgyer.com/apiv1/app/upload


fi

exit 0


