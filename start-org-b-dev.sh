./network.sh -m generate-peer -o b -e env

read -n1 -r -p "Press any key to UP orh..."

./network.sh -m up-one-org -o b

read -n1 -r -p "Press any key to join channel common "

#export API_PORT=4001
#export WWW_PORT=8082
#export CA_PORT=8054
#export PEER0_PORT=8051
#export PEER0_EVENT_PORT=8053
#export PEER1_PORT=8056
#export PEER1_EVENT_PORT=8058