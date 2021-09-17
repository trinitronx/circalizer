#!/bin/bash
#####################################################################
# Copyright © 🄯 2021  James Cuzella <james.cuzella@lyraphase.com>
#
# garmin-sleep-json2csv is free software:
# you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# garmin-sleep-json2csv is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
#####################################################################

# This script requires JQ
jq_bin="$(which jq)"
if [ ! -x "$jq_bin" ]; then
	echo -e "ERROR: jq utility is required!  Make sure it is available in your \$PATH" >&2
	exit 1
fi
# Source Input Data from GarminDB is stored in $HOME/HealthData
JSON_INPUT_FILES="${HOME}/HealthData/Sleep/*.json"

# Create CSV header row
echo '{}' | jq -r ' ["Sleep Start Local", "Sleep End Local", "Deep Sleep Seconds", "Light Sleep Seconds", "Awake Seconds"] | @csv'

# Extract non-null sleep timestamp values
# NOTE: todate function outputs something standard, that is (not surprisingly) difficult to import into .NET (go figure!)

# Equivalent .NET DateTime format specifier: \"yyyy-MM-dd HH:mm:ss\"
jq -r '.dailySleepDTO |
	   if has("sleepStartTimestampLocal") and has("sleepEndTimestampLocal") and .sleepStartTimestampLocal != null and .sleepEndTimestampLocal != null
	   then
		   [ (.sleepStartTimestampLocal / 1000 | strftime("%Y-%m-%d %H:%M:%S")), (.sleepEndTimestampLocal / 1000 | strftime("%Y-%m-%d %H:%M:%S")), .deepSleepSeconds, .lightSleepSeconds, .awakeSleepSeconds ]
	   else
		   empty
	   end |
	   @csv'    $JSON_INPUT_FILES
