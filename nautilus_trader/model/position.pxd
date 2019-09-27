# -------------------------------------------------------------------------------------------------
# <copyright file="position.pxd" company="Nautech Systems Pty Ltd">
#  Copyright (C) 2015-2019 Nautech Systems Pty Ltd. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  https://nautechsystems.io
# </copyright>
# -------------------------------------------------------------------------------------------------

from cpython.datetime cimport datetime

from nautilus_trader.model.objects cimport Quantity, Price
from nautilus_trader.model.events cimport OrderFillEvent
from nautilus_trader.model.identifiers cimport (
    Symbol,
    PositionId,
    OrderId,
    AccountId,
    ExecutionId,
    PositionIdBroker)
from nautilus_trader.model.c_enums.market_position cimport MarketPosition
from nautilus_trader.model.c_enums.order_side cimport OrderSide


cdef class Position:
    cdef set _order_ids
    cdef set _execution_ids
    cdef list _events

    cdef readonly PositionId id
    cdef readonly PositionIdBroker id_broker
    cdef readonly AccountId account_id
    cdef readonly ExecutionId last_execution_id

    cdef readonly OrderId from_order_id
    cdef readonly OrderId last_order_id
    cdef readonly datetime timestamp
    cdef readonly Symbol symbol
    cdef readonly OrderSide entry_direction
    cdef readonly datetime opened_time
    cdef readonly datetime closed_time
    cdef readonly object average_open_price
    cdef readonly object average_close_price
    cdef readonly object realized_points
    cdef readonly float realized_return
    cdef readonly OrderFillEvent last_event
    cdef readonly int event_count

    cdef readonly long _filled_quantity_buys
    cdef readonly long _filled_quantity_sells
    cdef readonly long relative_quantity
    cdef readonly Quantity quantity
    cdef readonly Quantity peak_quantity
    cdef readonly MarketPosition market_position
    cdef readonly bint is_open
    cdef readonly bint is_closed
    cdef readonly bint is_long
    cdef readonly bint is_short

    cdef bint equals(self, Position other)
    cpdef str status_string(self)
    cpdef list get_order_ids(self)
    cpdef list get_execution_ids(self)
    cpdef list get_events(self)
    cpdef void apply(self, OrderFillEvent event)
    cpdef object unrealized_points(self, Price current_price)
    cpdef float unrealized_return(self, Price current_price)

    cdef object _calculate_average_price(self, OrderFillEvent event, current_average_price, long total_fills)
    cdef object _calculate_points(self, opened_price, closed_price)
    cdef float _calculate_return(self, opened_price, closed_price)
    cdef void _on_event(self, OrderFillEvent event) except *
