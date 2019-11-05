SITE_NAME := "<empty>"

INITIAL_HOSTS := "127.0.0.1[7850],127.0.0.1[7950]"

clean:
	mvn clean

build:
	mvn compile

prepare:
	$(call prepare,SiteA,7800,7850,7850,7950)
	$(call prepare,SiteB,7900,7950,7850,7950)

define prepare
mkdir -p target/classes || true
cp src/main/resources/demo-local.xml target/classes/local-${1}.xml
cp src/main/resources/demo-global.xml target/classes/global-${1}.xml

awk '{sub(/DEMO_SITE_NAME/,"${1}")}1' \
    target/classes/local-${1}.xml \
    > target/classes/temp.xml \
    && mv target/classes/temp.xml target/classes/local-${1}.xml

awk '{sub(/DEMO_LOCAL_PORT/,"${2}")}1' \
    target/classes/local-${1}.xml \
    > target/classes/temp.xml \
    && mv target/classes/temp.xml target/classes/local-${1}.xml

awk '{sub(/DEMO_GLOBAL_PORT/,"${3}")}1' \
    target/classes/global-${1}.xml \
    > target/classes/temp.xml \
    && mv target/classes/temp.xml target/classes/global-${1}.xml

awk '{sub(/DEMO_GLOBAL_A_PORT/,"${4}")}1' \
    target/classes/global-${1}.xml \
    > target/classes/temp.xml \
    && mv target/classes/temp.xml target/classes/global-${1}.xml

awk '{sub(/DEMO_GLOBAL_B_PORT/,"${5}")}1' \
    target/classes/global-${1}.xml \
    > target/classes/temp.xml \
    && mv target/classes/temp.xml target/classes/global-${1}.xml
endef

exec:
	SITE_NAME=${SITE_NAME} mvn exec:java \
	-Dexec.mainClass="demo.Demo" \
	-Djava.net.preferIPv4Stack=true
