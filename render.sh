#!/bin/bash

for file in $(find . -name "*.puml")
do
    if [[ $file == *"/output"* ]]
    then
        continue
    fi
    outputBigFile=output/$(basename $(dirname $file))_$(basename $file)
    outputLocalFile=outputLocal/$(basename $(dirname $file))_$(basename $file)

    if [[ ! -d output ]]
    then
        mkdir output
    fi
    if [[ ! -d outputLocal ]]
    then
        mkdir outputLocal
    fi
    echo "" > $outputBigFile
    echo "" > $outputLocalFile
    echo "rendering file $file in $outputBigFile and $outputLocalFile"

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
                echo "$before[[file://$PWD/outputLocal/${component}_$fnct.svg $after]]" >> $outputLocalFile
                echo $line >> $outputBigFile
            else
                echo "$before[[file://$PWD/outputLocal/${component}_$fnct.svg $after]]" >> $outputLocalFile
                echo $line >> $outputBigFile
                #echo $before $after >> $outputBigFile
            fi
            echo "!includesub ${component}_$puml!${fnct#*.}" >> $outputBigFile
        elif [[ $line != "..." ]]
        then
            echo $line >> $outputBigFile
            echo $line >> $outputLocalFile
        else
            echo $line >> $outputLocalFile
        fi
    done < $file
done


createHtml() {
    java -DPLANTUML_LIMIT_SIZE=16384 -jar /var/lib/gems/2.5.0/gems/asciidoctor-diagram-2.0.1/lib/plantuml.jar -tsvg output/$1.puml
}

createHtml EdgeManager_boot
createHtml ApplicationManager_installApp
createHtml ApplicationManager_updateApp

java -DPLANTUML_LIMIT_SIZE=16384 -jar /var/lib/gems/2.5.0/gems/asciidoctor-diagram-2.0.1/lib/plantuml.jar -tsvg outputLocal/*.puml
