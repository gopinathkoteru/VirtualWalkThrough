cd $1
for folder in `ls`
do
	cd $folder
	
	echo "**************************************"
	echo $folder | grep "blur"
	for file in `ls`
	do
		if [ $file == "mobile_b" ] || [ $file == "mobile_d" ] || [ $file == "mobile_f" ] || [ $file == "mobile_l" ] || [ $file == "mobile_r" ] || [ $file == "mobile_u" ]
		then
			cd $file
			for img in `ls`
			do
				test=$img
				echo $test
				if [[ $img == "0.jpg" ]]
				then
					test="0_0.jpg"
					echo $test
				elif [[ $img == "1.jpg" ]]
				then
					test="0_1.jpg"
					echo $test
				elif [[ $img == "2.jpg" ]]
				then
					test="1_0.jpg"
					echo $test
				elif [[ $img == "3.jpg" ]]
				then
					test="1_1.jpg"
					echo $test
				fi
				mv $img $test
			done
			cd ..
		fi
	done
	cd ..
done

