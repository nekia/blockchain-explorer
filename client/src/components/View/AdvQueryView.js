/**
 *    SPDX-License-Identifier: Apache-2.0
 */

import React from 'react';
import View from '../Styled/View';
import { currentChannelType } from '../types';

export const AdvQueryView = ({ currentChannel }) => (
	<View>
		<iframe
			style={{ height: '960px', overflow: 'hidden', fontWeight: 'bold' }}
			title="Ledger Data Refiner - History"
			width="100%"
			overflow="hidden"
			src="http://localhost:30052/advance_embedded.html"
			target="_self"
		/>
	</View>
);

AdvQueryView.propTypes = {
	currentChannel: currentChannelType.isRequired
};

export default AdvQueryView;
