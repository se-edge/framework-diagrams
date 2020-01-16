#!/bin/bash

for file in $(find . -name "*.puml")
do
    if [[ $file == "./output/"* ]]
    then
        continue
    fi
    outputFile=output/$(basename $(dirname $file))_$(basename $file)
    echo "" > $outputFile
    echo "rendering file $file in $outputFile"

    while read line
    do
        if [[ $line == *\[\[*\]\]* ]]
        then
            before=$(echo $line | sed 's/\(.*\)\[\[\([^ ]*\) \(.*\)\]\].*/\1/')
            url=$(echo $line | sed 's/\(.*\)\[\[\([^ ]*\) \(.*\)\]\].*/\2/')
            after=$(echo $line | sed 's/\(.*\)\[\[\([^ ]*\) \(.*\)\]\].*/\3/')
            component=$(echo $url | sed 's#http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/se-edge/diagrams/develop/\(.*\)/\(.*\)&.*#\1#')
            puml=$(echo $url | sed 's#http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/se-edge/diagrams/develop/\(.*\)/\(.*\)&.*#\2#')
            fnct=$(echo $puml | sed 's/\(.*\)\.puml/\1/')

            if [[ $line == "note "* ]]
            then
                echo $line >> $outputFile
                line="!includesub ${component}_$puml!$fnct"
            else
                echo $line >> $outputFile
                #echo $before $after >> $outputFile
                line="!includesub ${component}_$puml!$fnct"
            fi

        fi
        if [[ $line == "..." ]]
        then
            line=""
        fi
        echo $line >> $outputFile
    done < $file
done


createHtml() {
    puml=$1.puml
    java -DPLANTUML_LIMIT_SIZE=16384 -jar /var/lib/gems/2.5.0/gems/asciidoctor-diagram-2.0.1/lib/plantuml.jar output/$1.puml

    echo "<img src=\"$1.png\" usemap=\"#${1}_map\" />" > output/$1.html

    if [[ -f output/$1.cmapx ]]
    then
        cat output/$1.cmapx >> output/$1.html
    fi
}

createHtml EdgeManager_boot
