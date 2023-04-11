#!/bin/sh

if [ $# -ne 2 ]
then
    echo "usage: $0 <SRC EBS_VERSION> <TRG EBS_VERSION>"
    exit 1
fi

SRC_EBS_VERSION=$1
TRG_EBS_VERSION=$2
SUB_DIR=ebs_cr_$1_$2
ZIP_FILENAME=export_ebs_cr_dn_${SRC_EBS_VERSION}_${TRG_EBS_VERSION}.zip 

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
add_commit() {
INFILE=$1
OUTFILE=$2
echo "Adding commits to $INFILE..."
TOTAL_LINES=`wc -l ${INFILE} | awk '{print $1}'`
cat $INFILE \
    | awk -v total_lines=${TOTAL_LINES} \
'BEGIN{insert_cnt=0;
line_cnt=0;
max_line=total_lines-3;}
{
    line_cnt = line_cnt+1;
    if ( $0 ~ "Insert into" ) {
        insert_cnt = insert_cnt+1;
        if ( insert_cnt == 100 ) {
            print("COMMIT;");
            insert_cnt=0;
        }
    }
    if ( line_cnt <= max_lines ) {
        print $0;
    } else {
        if ( ! ($0 ~ "^$" || $0 ~ "rows selected" ) ) {
            print $0;
        }
    }
}END{print("COMMIT;");}' > $OUTFILE
}

################################################################################
# Main
################################################################################

mkdir ${SUB_DIR}
/bin/rm -f ${SUB_DIR}/export_dn_commit.sql      2>/dev/null
/bin/rm -f ${SUB_DIR}/export_dn_text_commit.sql 2>/dev/null
add_commit export_dn.sql                     ${SUB_DIR}/export_dn_commit.sql
add_commit export_dn_text.sql                ${SUB_DIR}/export_dn_text_commit.sql
cp -p schema-dn-tables.ddl                   ${SUB_DIR}/.
cp -p schema-dn-indexes-constraints.ddl      ${SUB_DIR}/.
cp -p schema-dn-drop-indexes-constraints.ddl ${SUB_DIR}/.
cp -p README_IMPORT.txt                      ${SUB_DIR}/.

echo "Zipping package into ${ZIP_FILENAME}..."
/bin/rm ${ZIP_FILENAME} 2>/dev/null
zip -r ${ZIP_FILENAME} ${SUB_DIR}

echo "Done"

