#!/bin/bash

set -e

rm -rf ../data
mkdir -p ../data

mkdir -p ../data/creators
mkdir -p ../data/users
mkdir -p ../data/get-by-market-details
mkdir -p ../data/collectibles

creators=0
users=0
get_by_market_details=0
collectibles=0

d=`date`

echo "------------- "
echo " Curador - Discover artists by their art "
echo "------------- "
echo " started_at: ${d}"
echo " "


# /creators

# All Time: "startDate":null,"endDate":null

# orderBy
# -------
# TOTAL_SALES_DESC
# TOTAL_SALES_USD_DESC

# pagination
# ----------
# false

curl -s 'https://superrare.co/api/v2/stats/creators' \
  -H 'authority: superrare.co' \
  -H 'pragma: no-cache' \
  -H 'cache-control: no-cache' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.192 Safari/537.36' \
  -H 'content-type: application/json;charset=UTF-8' \
  -H 'origin: https://superrare.co' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'referer: https://superrare.co/top-artists' \
  -H 'accept-language: en-US,en;q=0.9' \
  --data-raw '{"contractAddresses":["0x41a322b28d0ff354040e2cbc676f0320d8c8850d","0xb932a70a57673d89f4acffbe830e8ed7f75fb9e0"],"startDate":null,"endDate":null,"orderBy":"TOTAL_SALES_DESC"}' \
  --compressed > ../data/creators/creators.tmp

creators=$((creators+1))

cat ../data/creators/creators.tmp | jq . > ../data/creators/creators.json && rm -rf ../data/creators/creators.tmp

usernames=(`jq .result.statsWithUsers[].userProfile.username ../data/creators/creators.json`)
for username in "${usernames[@]}"
do
  username=${username//\"/}

  echo ""
  echo " > ${username}"

  # / user

  # pagination
  # ----------
  # false

  curl -s "https://superrare.co/api/v2/user?username=${username}"  \
    -H 'authority: superrare.co' \
    -H 'pragma: no-cache' \
    -H 'cache-control: no-cache' \
    -H 'accept: application/json, text/plain, */*' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.192 Safari/537.36' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-dest: empty' \
    -H "referer: https://superrare.co/${username}" \
    -H 'accept-language: en-US,en;q=0.9' \
    --compressed > ../data/users/${username}.tmp

  users=$((users+1))

  cat ../data/users/${username}.tmp | jq . > ../data/users/${username}.json && rm -rf ../data/users/${username}.tmp

  # userId
  userId=`jq .result.userId ../data/users/${username}.json`
  userId=${userId//\"/}
  echo " > ${userId}"

  # ethereumAddress
  ethereumAddress=`jq .result.ethereumAddress ../data/users/${username}.json`
  ethereumAddress=${ethereumAddress//\"/}
  echo " > ${ethereumAddress}"
  echo ""

  # / get-market-details

  # pagination
  # ----------
  # false

  data='{"contractAddresses":["0x41a322b28d0ff354040e2cbc676f0320d8c8850d","0xb932a70a57673d89f4acffbe830e8ed7f75fb9e0"],"hasBidWithAuctionAddressses":null,"hasSalePriceWithMarketAddresses":null,"previousCursor":null,"last":null,"ownedByCreator":null,"creatorAddress":"ethereumAddress","includeBurned":false,"orderBy":"TOKEN_ID_DESC","hasEndingAuctionInContractAddresses":null,"hasReservePriceWithAuctionHouseContractAddresses":null}'
  data=${data//ethereumAddress/$ethereumAddress}

  curl -s 'https://superrare.co/api/v2/nft/get-by-market-details' \
    -H 'authority: superrare.co' \
    -H 'pragma: no-cache' \
    -H 'cache-control: no-cache' \
    -H 'accept: application/json, text/plain, */*' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.192 Safari/537.36' \
    -H 'content-type: application/json;charset=UTF-8' \
    -H 'origin: https://superrare.co' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-dest: empty' \
    -H 'referer: https://superrare.co' \
    -H 'accept-language: en-US,en;q=0.9' \
    --data-raw ${data} \
    --compressed > ../data/get-by-market-details/${username}.tmp

  get_by_market_details=$((get_by_market_details+1))

  cat ../data/get-by-market-details/${username}.tmp | jq . > ../data/get-by-market-details/${username}.json && rm -rf ../data/get-by-market-details/${username}.tmp

  # .result.collectibles[].tokenId
  tokens=(`jq ''.result.collectibles[].tokenId ../data/get-by-market-details/${username}.json`)

  # .result.collectibles[].standardImage
  images=(`jq ''.result.collectibles[].standardImage ../data/get-by-market-details/${username}.json`)
  for index in "${!images[@]}"
  do
    image=${images[$index]}
    image=${image//\"/}

    filename=${image//https:\/\/ipfs.pixura.io\/ipfs\//}
    filename=${filename//\//-}

    if [ "$filename" != "null" ]; then
      tokenId=${tokens[$index]}
      filename="${tokenId}-${filename}"

      mkdir -p ../data/collectibles/${username}

      echo "   - ${filename}"
      # curl -s ${image} -o  ../data/collectibles/${username}/${filename}

      collectibles=$((collectibles+1))
    fi

  done

done

echo "------------- "
echo " creators: ${creators} "
echo " users: ${users} "
echo " get_by_market_details: ${get_by_market_details} "
echo " collectibles: ${collectibles} "
echo "------------- "

date
