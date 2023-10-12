#! /bin/bash

# Function to display the main menu
function displayMainMenu {
    echo $'Enter Your Choice: \n'
    select option in 'Create Database' 'List Databases' 'Connect to Database' 'Drop Database' 'Exit'
    do
        case $option in
        'Create Database')
            echo $'\n'
            createDatabase
            ;;
        'List Databases')
            echo $'\n'
            listDatabases
            ;;
        'Connect to Database')
            connectToDatabase
            ;;
        'Drop Database')
            dropDatabase
            ;;
        'Exit')
            exit
            ;;
        *)
            echo $'\n'
            echo "Invalid choice!"
            ;;
        esac
    done
}
#-----------------------------------------------
#-------------------------------------------------
function checkName() {
if [[ $1 == *[0-9'!'@#,:\$%^\&-*()_+" "]* ]]
then echo "$1 Name Is Invalid"
$2  
fi
}
#---------------------------------------------------
#---------------------------------------------------
# Function to create a new database
function createDatabase {
    echo $'Enter Database Name:\t'
    read dbName
    checkName $dbName displayMainMenu
    if ! [[ -d ./Databases/$dbName ]]
    then
        mkdir -p ./Databases/$dbName 2> /dev/null
        echo "$dbName Created Successfully"
        displayMainMenu
        
    else
        echo "The Database $dbName already exists"
        displayMainMenu
    fi
}
#--------------------------------------------
#--------------------------------------------
# Function to drop a Database
function dropDatabase {
    echo $'Enter DataBase Name:\t'
    read dbName
    if [[ -d ./Databases/$dbName ]]
    then
        rm -r ./Databases/$dbName 2> /dev/null
        echo "$dbName Removed Successfully"
    else
        echo "Database Not found"
    fi
}
#--------------------------------------------------
#--------------------------------------------------
# Function to list all Databases in the directory
function listDatabases {
    ls -1 ./Databases 2> /dev/null
    echo ''
}
#----------------------------------------------------
#----------------------------------------------------
# Function to connect to an existing Database
function connectToDatabase {
    echo $'Enter Database Name:\n'
    read dbName
    if [[ -d ./Databases/$dbName ]]
    then
        cd ./Databases/$dbName 2> /dev/null
        echo "Connected to $dbName"
        manageTables
    else
        echo "Database $dbName wasn't found"
        displayMainMenu
    fi
}
#------------------------------------------
#------------------------------------------
# Function to display Table Menu
function manageTables {
    echo $'Enter Choice:\n'
    select action in 'Create Table' 'List Tables' 'Drop Table' 'Insert into Table' 'Select From Table' 'Delete From Table' 'Update Table' 'Main Menu' 'Exit'
    do
        case $action in
        'Create Table')
            createTableFunction
            ;;
        'List Tables')
            listTablesFunction
            ;;
        'Drop Table')
            dropTableFunction
            ;;
        'Insert into Table')
            insertRecordFunction
            ;;
        'Select From Table')
            selectRecordFunction
            ;;
        'Delete From Table')
            deleteRecordFunction
            ;;
        'Update Table')
            updateRecordFunction
            ;;
        'Main Menu')
            cd ../..
            displayMainMenu
            ;;
        'Exit')
            exit
            ;;
        *)
            echo "Wrong Choice"
            manageTables
            ;;
        esac
    done
}
#---------------------------------------
#---------------------------------------
# Function to create a new table
function createTableFunction {
    echo $'Table Name:\n'
    read tableName
    checkName $tableName manageTables
    if [[ -f $tableName ]]
    then
        echo "Table $tableName already exists!"
        manageTables
    else
        touch $tableName
        echo "Table $tableName created successfully!"
    fi

    echo "Number of Columns: "
    read numFields
    num='^[0-9]+$'
    if [[ $numFields =~ $num ]]
    then

        # Flag to check if a field is a primary key
        isPrimaryKey="true"
        for ((i=1; i<=$numFields; i++))
        do
            echo -n "Name of Column no.$i: "
            read fieldName
            while true
            do
		    if [[ $fieldName == *[0-9'!'@#,:\$%^\&-*()_+" "]* ]]
		    then
			echo "$fieldName is invalid name"
			echo -n "Name of Column no.$i: "
                        read fieldName
                    else
                            fname=$(grep $fieldName $tableName)
                            if ! [[ $fname == "" ]]
                            then
		                   echo "already exist"
		                   echo -n "Name of Column no.$i: "
		                   read fieldName
                           else
                             break
                           fi
		            
		   fi
	   done
            # Set the primary key
            while [ $isPrimaryKey == "true" ]
            do
                echo "Is this a primary key? [Y/N]"
                read primaryKey
                if [[ $primaryKey == "Y" || $primaryKey == "y" || $primaryKey == "yes" ]]
                then
                    isPrimaryKey="false"
                    echo -n "(PK)" >> $tableName
                else
                    break
                fi
            done

            # Set the column data type
            while true
            do
                echo "Choose data type from (int, str)"
                read dataType
                case $dataType in
                int)
                    echo -n "$fieldName($dataType);" >> $tableName
                    ;;
                str)
                    echo -n "$fieldName($dataType);" >> $tableName
                    ;;
                *)
                    echo "DataType is incorrect!"
                    continue
                    ;;
                esac
                break
            done
        done

        echo $'\n' >> $tableName # End of table header
        echo "Table $tableName created successfully!"
        manageTables
    else
        echo "$numFields is not a valid input (numbers only)"
        createTableFunction
    fi
}
#---------------------------------
#---------------------------------
# Function to list all tables
function listTablesFunction {
    echo $'Your current tables are:\n'
    ls -1 2> /dev/null

}
#------------------------------------------
#------------------------------------------
# Function to drop a table
function dropTableFunction {
    echo $'Enter Table Name:\t'
    read tableName

    if [[ -f $tableName ]]
    then
        rm $tableName 2> /dev/null
        echo "Table $tableName is Deleted!"
    else
        echo "Table $tableName wasn't found"
    fi
}
#--------------------------------
#---------------------------------
# Function to insert a record into a table
function insertRecordFunction {
    echo "Enter Table Name: "
    read tableName
    
    if [[ -f $tableName ]]
    then
        numFields=$(grep 'PK' $tableName | grep -o ";" | wc -l) # Number of fields

        for ((i=1; i <= numFields; i++))
        do
            columnName=$(grep PK $tableName | cut -f$i -d";")
            echo $'\n'
            echo $"Enter Column no.$i [$columnName]"
            read data
            checkDataTypeForInsert $i $data

            if [[ $? != 0 ]]
            then
                ((i = $i - 1))
            else
                echo -n "$data;" >> $tableName
            fi
        done
        echo $'\n' >> $tableName # End of record
        echo "Insert into $tableName completed successfully!"
        manageTables
    else
        echo "Table doesn't exist"
        manageTables
    fi
}
#---------------------------------
#---------------------------------
# Function to select records from a table
function selectRecordFunction {
    echo "Enter Table Name: "
    read tableName

    if [[ -f $tableName ]]
    then
        echo $'\n'
        awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $tableName
        echo $'\nWould you like to Select All Rows? [y/n]'
        read printAll
        if [[ $printAll == "Y" || $printAll == "y" || $printAll == "yes" ]]
        then
            echo $'\nWould you like to Select a Specific Column? [y/n]'
            read cut1
            if [[ $cut1 == "Y" || $cut1 == "y" || $cut1 == "yes" ]]
            then
                echo $'\nEnter Specify Column Number: '
                read fieldNo
                echo $'<====================>'
                awk '{print $0}' $tableName | cut -f$fieldNo -d";"
                echo $'<====================>'
            else
                echo $'\n'
                echo $'<====================>'
                column -t -s ';' $tableName
                echo $'<====================>\n'
            fi
        else
        #select row by column or all
            echo $'\nEnter Value: '
            read value
            echo $'\nWould you like to Select a Specific Column? [y/n]'
            read cut
            if [[ $cut == "Y" || $cut == "y" || $cut == "yes" ]]
            then
                echo $'\nPlease Specify Column Number: '
                read field
                echo $'<====================>\n'
                # Find the pattern in records, filtering for that specific field
                awk -v pat="$value" '$0 ~ pat {print $0}' $tableName | cut -f$field -d";"
                echo $'<====================>'
            else
                echo $'<====================>\n'
                # Find the pattern in records, printing all fields as a table display
                awk -v pat="$value" '$0 ~ pat {print $0}' $tableName | column -t -s ';'
            fi
        fi
        
    else
        echo "Table doesn't exist"
        manageTables
    fi
}
#-----------------------------------
#-----------------------------------
# Function to delete a record from a table
function deleteRecordFunction {
    echo "Enter Table Name: "
    read tableName

    if [[ -f $tableName ]]
    then
        # Display table header
        awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $tableName
        echo "Enter Column Name:"
        read field

        # Get the field number
        findex=$(awk -F";" -v field="$field" 'NR==1 {for (i=1; i<=NF; i++) if ($i == field) print i}' $tableName)

        if [[ -z $findex ]]
        then
            echo "Column Not Found"
            manageTables
        else
            echo "Enter Value:"
            read value
            # Display the row to be deleted
            echo "Row to be deleted:"
            row=$(awk -v findex="$findex" -v value="$value" -F";" '$findex == value' $tableName 2> /dev/null )
            echo $row
            if ! [[ -z $row ]]
            then
                  # Confirm deletion
                  awk -v findex="$findex" -v value="$value" -F";" '$findex != value' $tableName > tmpfile && mv tmpfile $tableName
                  if [[ $? -eq 0 ]]
                  then
                      echo "Row Deleted Successfully"
               	  else
                      echo "Error: Failed to delete row"
               	  fi
            else
                echo "value Not Found"
            	manageTables
              fi
         fi
    else
        echo "Table doesn't exist"
        manageTables
        
    fi
}
#----------------------------------
#-------------------------------------
# Function to update a record in a table
function updateRecordFunction {
    echo "Enter Table Name:"
    read tableName
    if [[ -f $tableName ]]
    then
	    awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $tableName
	    echo "Enter Column name: "
	    read field
	    findex=$(awk 'BEGIN{FS=";"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $tableName )
	    if [[ $findex == "" ]]
	    then
		echo "Not Found"
		manageTables
	    else
		echo "Enter Value:"
		read value
		result=$(awk 'BEGIN{FS=";"}{if ($'$findex'=="'$value'") print $'$findex'}' $tableName 2>> /dev/null)
		if [[ $result == "" ]]
		then
		    echo "Value Not Found"
		    manageTables
		else
		    echo "Enter new Value to set:"
		    read newValue
		    checkDataTypeForInsert $findex $newValue
		     if [[ $? != 0 ]]
                     then
                            echo "Error: Failed to update row"
                     else
                         
			    NR=$(awk 'BEGIN{FS=";"}{if ($'$findex' == "'$value'") print NR}' $tableName 2>> /dev/null)
			    echo $NR
			    oldValue=$(awk 'BEGIN{FS=";"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$findex') print $i}}}' $tableName 2>> /dev/null)
			    echo $oldValue
			    sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tableName 2>> /dev/null
			    echo "Row Updated Successfully"
			    manageTables
                     fi
		fi
	    fi
    else
        echo "Table doesn't exist"
        manageTables
     fi
}
#-------------------------------------
#-------------------------------------
# Function to check data type for a field during insertion
function checkDataTypeForInsert {
    dataType=$(grep PK $tableName | cut -f$1 -d";")

    # Check if it's an integer column
    if [[ "$dataType" == *"int"* ]]
    then
        num='^[0-9]+$'
        if ! [[ $2 =~ $num ]]
        then
            echo "False input: Not a number!"
            return 1
        else
            checkPrimaryKeyForInsert $1 $2
        fi
    elif [[ "$dataType" == *"str"* ]]
    then
        str='^[a-zA-Z]+$'
        if ! [[ $2 =~ $str ]]
        then
            echo "False input: Not a valid string!"
            return 1
        else
            checkPrimaryKeyForInsert $1 $2
        fi
    fi
}
#---------------------------------------
#---------------------------------------
# Function to check if a field is a primary key during insertion
function checkPrimaryKeyForInsert {
    header=$(grep PK $tableName | cut -f$1 -d";")
    if [[ "$header" == *"PK"* ]]
    then
        if [[ $(cut -f$1 -d";" $tableName | grep -w $2) ]]
        then
            echo $'\nPrimary Key already exists.'
            return 1
        fi
    fi
}
#-------------------------------------------------------

# Start the main menu
displayMainMenu



