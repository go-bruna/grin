// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

#![allow(clippy::crate_in_macro_def)]
#![allow(clippy::too_many_arguments)]

use i2p_router::{router_event_loop, setup_router, ui::web::RouterUi, RouterContext};
use tokio::sync::mpsc::{channel, Receiver};

pub fn start_i2p_router() -> anyhow::Result<()> {
	let runtime = tokio::runtime::Runtime::new()?;
	let (shutdown_tx, shutdown_rx) = channel(1);
	let RouterContext {
		router,
		port_mapper,
		events,
		router_ui_config,
	} = runtime.block_on(setup_router())?;

	runtime.spawn(async move {
		RouterUi::new(events, Some(7657), 5, shutdown_tx)
			.run()
			.await;
	});
	// runtime.block_on(router_event_loop(router, port_mapper, shutdown_rx));

	Ok(())
}
