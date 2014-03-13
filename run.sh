#!/bin/sh
VIDEO_MP4=true;
VIDEO_WEBM=true;
#VIDEO_SIZE="854x480";
VIDEO_SIZE="1280x720";
VIDEO_BITRATE="1000k";
VIDEO_PASS=2;

AUDIO_BITRATE="128k";
AUDIO_SAMPLE_RATE="44100";

# create output folder if not exists
if [ ! -d output ]; then
    mkdir output;
fi


# encode audios
for i in src/*.mp3 ;
do
    if [ -f $i ]; then
        DESTINATION="$(echo $i | sed 's/src\//output\//')";
        echo "Encoding audio: $i";

        bin/ffmpeg -loglevel panic -i $i -codec:a libmp3lame -b:a $AUDIO_BITRATE -ar $AUDIO_SAMPLE_RATE -f mp3 -y "$(echo $DESTINATION | sed 's/\.mp3/\.mp3/')";
        bin/ffmpeg -loglevel panic -i $i -codec:a libvorbis -b:a $AUDIO_BITRATE -ar $AUDIO_SAMPLE_RATE -f ogg -y "$(echo $DESTINATION | sed 's/\.mp3/\.ogg/')";
    fi
done


# delete temporary folder if exists
if [ -d tmp ]; then
    rm -R tmp/
fi

# create temporary folder
mkdir tmp;


# encode videos
for i in src/*.mov ;
do
    if [ -f $i ]; then
        DESTINATION="$(echo $i | sed 's/src\//output\//')";
        TEMP="$(echo $i | sed 's/src\//tmp\//')";

        if [ "$VIDEO_WEBM" = true ]; then

            echo "Encoding video: $i to WebM - VP8 - Vorbis";

            if [ $VIDEO_PASS -ge 2 ]; then
                bin/ffmpeg -i $i -s $VIDEO_SIZE -codec:v libvpx -cpu-used 0 -b:v $VIDEO_BITRATE -an -pass 1 -passlogfile tmp/passlog.dv -f webm -y /dev/null
                bin/ffmpeg -i $i -s $VIDEO_SIZE -codec:v libvpx -cpu-used 0 -b:v $VIDEO_BITRATE -codec:a libvorbis -b:a $AUDIO_BITRATE -ar $AUDIO_SAMPLE_RATE -pass 2 -passlogfile tmp/passlog.dv -f webm -y "$(echo $DESTINATION | sed 's/\.mov/\.webm/')";
            fi

            if [ $VIDEO_PASS -eq 1 ]; then
                bin/ffmpeg -i $i -s $VIDEO_SIZE -codec:v libvpx -cpu-used 0 -b:v $VIDEO_BITRATE -codec:a libvorbis -b:a $AUDIO_BITRATE -ar $AUDIO_SAMPLE_RATE -f webm -y "$(echo $DESTINATION | sed 's/\.mov/\.webm/')";
            fi

        fi



        if [ "$VIDEO_MP4" = true ]; then

            echo "Encoding video: $i to MP4 - H.264 - AAC";

            if [ $VIDEO_PASS -ge 2 ]; then
                bin/ffmpeg -i $i -s $VIDEO_SIZE -codec:v libx264 -vprofile main -b:v $VIDEO_BITRATE -an -pass 1 -passlogfile tmp/passlog.dv -f mp4 -y /dev/null
                bin/ffmpeg -i $i -s $VIDEO_SIZE -codec:v libx264 -vprofile main -b:v $VIDEO_BITRATE -codec:a libvo_aacenc -b:a $AUDIO_BITRATE -ar $AUDIO_SAMPLE_RATE -pass 2 -passlogfile tmp/passlog.dv -f mp4 -y "$(echo $TEMP | sed 's/\.mov/\.mp4/')";
            fi

            if [ $VIDEO_PASS -eq 1 ]; then
                bin/ffmpeg -i $i -s $VIDEO_SIZE -codec:v libx264 -vprofile main -b:v $VIDEO_BITRATE -codec:a libvo_aacenc -b:a $AUDIO_BITRATE -ar $AUDIO_SAMPLE_RATE -f mp4 -y "$(echo $TEMP | sed 's/\.mov/\.mp4/')";
            fi

            bin/qtfaststart/bin/qtfaststart "$(echo $TEMP | sed 's/\.mov/\.mp4/')" "$(echo $DESTINATION | sed 's/\.mov/\.mp4/')";
        fi

    fi
done

# remove temporary folder
rm -R tmp/