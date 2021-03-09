/**
 *    SPDX-License-Identifier: Apache-2.0
 */

import React from 'react';
import { currentChannelType } from '../types';

export const HistoryView = ({ currentChannel }) => (
	<div>
		{/* <iframe src='http://localhost:30052/history_embedded.html'/> */}
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<p>Test History View</p>
		<iframe
			title="Ledger Data Refiner - History"
			width="960px"
			height="640"
			src="http://localhost:30052/history_embedded.html"
			target="_self"
		/>
	</div>
);

HistoryView.propTypes = {
	currentChannel: currentChannelType.isRequired
};

export default HistoryView;
