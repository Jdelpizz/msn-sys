import PropTypes from 'prop-types'
import {
  Card,
  Circle,
  Divider,
  Heading,
  HStack,
  Stack,
  Text,
} from '@chakra-ui/react'

const {VITE_SHOPS} = import.meta.env
const SHOPS = VITE_SHOPS.toLowerCase().split(' ')

function MetaSection({label, value}){
  const metaFontSize = "1.2em"
  return (
    <HStack>
      <Text fontSize={metaFontSize} fontWeight="bold">{`${label}:`}</Text>
      <Text fontSize={metaFontSize}>{value.toUpperCase()}</Text>
    </HStack>
  )
}

MetaSection.defaultProps = {
  value: 'unk'
}

MetaSection.propTypes = {
  label: PropTypes.string.isRequired,
  value: PropTypes.string
}

function MissionMeta({intel}){
  const {
    msn_takeoff: msnTakeoff,
    msn_return: msnReturn,
    msn_platform: msnPlatform,
    msn_target: msnTarget
  } = intel
  return (
    <Stack>
      <Heading size="md">Mission Data</Heading>
      <Divider />
      <HStack justifyContent="center" spacing={8}>
        <MetaSection label="Takeoff" value={msnTakeoff} />
        <MetaSection label="Return" value={msnReturn} />
        <MetaSection label="Platform" value={msnPlatform} />
        <MetaSection label="Target" value={msnTarget} />
      </HStack>
    </Stack>
  )
}

MissionMeta.defaultProps = {
  intel: PropTypes.shape({
    msn_takeoff: 'unk',
    msn_return: 'unk',
    msn_platform: 'unk',
    msn_target: 'unk',
  })
}

MissionMeta.propTypes = {
  intel: PropTypes.shape({
    msn_id: PropTypes.string,
    msn_takeoff: PropTypes.string,
    msn_return: PropTypes.string,
    msn_platform: PropTypes.string,
    msn_target: PropTypes.string,
  })
}

function Status({label, state, delay}){
  const statusColor = {
    "good": "green.500",
    "unk": "gray.500"
  }

  return (
    <HStack>
      <Circle size={6} bg={statusColor[state]} transition={`all 0.5s ${delay}s`} />
      <Text fontSize="1.8em" fontWeight="bold">{label.toUpperCase()}</Text>
    </HStack>
  )
}

Status.propTypes = {
  label: PropTypes.string.isRequired,
  state: PropTypes.string.isRequired,
  delay: PropTypes.number.isRequired
}

function MissionStatus({states}){
  return (
    <Stack>
      <Heading size="md">Mission Status</Heading>
      <Divider />
      <HStack justifyContent="center" spacing={4}>
        {SHOPS.map((shop, idx) => {
          const currentState = states[shop] && states[shop].status ? states[shop].status : 'unk'
          const delay = idx * 0.5

          return(
            <Status key={shop} label={shop} state={currentState} delay={delay} />
          )})}
      </HStack>
    </Stack>
  )
}

MissionStatus.propTypes = {
  states: PropTypes.shape({
    intel: PropTypes.shape({
      status: PropTypes.string
    })
  }).isRequired
}

export default function AirTaskingOrderCard({msnData}){
  // The defaultProps get overwritten when an empty object is passed in
  // There must be a better pattern for this
  const {intel = {}} = msnData
  var {msn_id: msnId = "unk"} = intel
  console.log(msnData)
  if(msnData.hasOwnProperty('intel')){
    msnId = msnData.intel.msn_id
  }
  else{
    msnData = {"intel":{}}
  }
  return (
    <Card px={4} py={2}>
      <Stack spacing={6}>
        <Heading size="lg">{`Mission ${msnId ? msnId.toUpperCase(): ""}`}</Heading>
        <MissionStatus states={msnData} />
        <MissionMeta intel={msnData.intel}/>
      </Stack>
    </Card>
  )
}

AirTaskingOrderCard.defaultProps = {
  msnData: {
    intel: {
      msn_id: 'unk'
    }
  }
}

AirTaskingOrderCard.propTypes = {
  msnData: PropTypes.shape({
    intel: PropTypes.shape({
      msn_id: PropTypes.string,
      msn_takeoff: PropTypes.string,
      msn_return: PropTypes.string,
      msn_platform: PropTypes.string,
      msn_target: PropTypes.string,
    })
  })
}
