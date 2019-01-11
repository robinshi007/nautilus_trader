#!/usr/bin/env python3
# -------------------------------------------------------------------------------------------------
# <copyright file="events.pyx" company="Invariance Pte">
#  Copyright (C) 2018-2019 Invariance Pte. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  http://www.invariance.com
# </copyright>
# -------------------------------------------------------------------------------------------------

# cython: language_level=3, boundscheck=False, wraparound=False

from cpython.datetime cimport datetime

from inv_trader.core.precondition cimport Precondition
from inv_trader.core.decimal cimport Decimal
from inv_trader.enums.brokerage cimport Broker
from inv_trader.enums.currency_code cimport CurrencyCode
from inv_trader.enums.order_side cimport OrderSide
from inv_trader.enums.order_type cimport OrderType
from inv_trader.enums.time_in_force cimport TimeInForce
from inv_trader.model.identifiers cimport GUID, Label, AccountNumber, AccountId
from inv_trader.model.identifiers cimport OrderId, ExecutionId, ExecutionTicket
from inv_trader.model.objects cimport Symbol


cdef class Event:
    """
    The abstract base class for all events.
    """

    def __init__(self,
                 GUID identifier,
                 datetime timestamp):
        """
        Initializes a new instance of the Event abstract class.

        :param identifier: The events identifier.
        :param timestamp: The events timestamp.
        """
        self.id = identifier
        self.timestamp = timestamp

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return self.id == other.id
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(self.id)

    def __str__(self) -> str:
        """
        :return: The str() string representation of the event.
        """
        return f"{self.__class__.__name__}()"

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the event.
        """
        return f"<{str(self)} object at {id(self)}>"


cdef class AccountEvent(Event):
    """
    Represents an account event produced from a collateral report.
    """

    def __init__(self,
                 AccountId account_id,
                 Broker broker,
                 AccountNumber account_number,
                 CurrencyCode currency,
                 Decimal cash_balance,
                 Decimal cash_start_day,
                 Decimal cash_activity_day,
                 Decimal margin_used_liquidation,
                 Decimal margin_used_maintenance,
                 Decimal margin_ratio,
                 str margin_call_status,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the Bar class.

        :param currency: The currency for the account.
        :param cash_balance: The events account cash balance.
        :param cash_start_day: The events account cash start of day.
        :param cash_activity_day: The events account activity for the trading day.
        :param margin_used_liquidation: The events margin used before liquidation.
        :param margin_used_maintenance: The events margin used for maintenance.
        :param margin_ratio: The events account margin ratio.
        :param margin_call_status: The events margin call status (can be empty).
        :param event_id: The events identifier.
        :param event_timestamp: The order events timestamp.
        """
        Precondition.not_negative(cash_balance, 'cash_balance')
        Precondition.not_negative(cash_start_day, 'cash_start_day')
        Precondition.not_negative(cash_activity_day, 'cash_activity_day')
        Precondition.not_negative(margin_used_liquidation, 'margin_used_liquidation')
        Precondition.not_negative(margin_used_maintenance, 'margin_used_maintenance')
        Precondition.not_negative(margin_ratio, 'margin_ratio')

        super().__init__(event_id, event_timestamp)
        self.account_id = account_id
        self.broker = broker
        self.account_number = account_number
        self.currency = currency
        self.cash_balance = cash_balance
        self.cash_start_day = cash_start_day
        self.cash_activity_day = cash_activity_day
        self.margin_used_liquidation = margin_used_liquidation
        self.margin_used_maintenance = margin_used_maintenance
        self.margin_ratio = margin_ratio
        self.margin_call_status = margin_call_status

    def __str__(self) -> str:
        """
        :return: The str() string representation of the event.
        """
        return (f"{self.__class__.__name__}"
                f"(order_id={self.cash_balance}, margin_used={self.margin_used_maintenance})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the event.
        """
        return f"<{str(self)} object at {id(self)}>"


cdef class OrderEvent(Event):
    """
    The abstract base class for all order events.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderEvent abstract class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param event_id: The events identifier.
        :param event_timestamp: The order events timestamp.
        :raises ValueError: If the order_id is not a valid string.
        """
        super().__init__(event_id, event_timestamp)
        self.symbol = symbol
        self.order_id = order_id

    def __str__(self) -> str:
        """
        :return: The str() string representation of the event.
        """
        return f"{self.__class__.__name__}(id={self.order_id})"

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the event.
        """
        return f"<{str(self)} object at {id(self)}>"


cdef class OrderSubmitted(OrderEvent):
    """
    Represents an event where an order has been submitted to the execution system.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 datetime submitted_time,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderSubmitted class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param submitted_time: The events order submitted time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.submitted_time = submitted_time


cdef class OrderAccepted(OrderEvent):
    """
    Represents an event where an order has been accepted by the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 datetime accepted_time,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderAccepted class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param accepted_time: The events order accepted time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.accepted_time = accepted_time


cdef class OrderRejected(OrderEvent):
    """
    Represents an event where an order has been rejected by the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 datetime rejected_time,
                 str rejected_reason,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderRejected class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param rejected_time: The events order rejected time.
        :param rejected_reason: The events order rejected reason.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        Precondition.valid_string(rejected_reason, 'rejected_reason')

        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.rejected_time = rejected_time
        self.rejected_reason = rejected_reason


cdef class OrderWorking(OrderEvent):
    """
    Represents an event where an order is working with the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 OrderId broker_order_id,
                 Label label,
                 OrderSide order_side,
                 OrderType order_type,
                 int quantity,
                 Decimal price,
                 TimeInForce time_in_force,
                 datetime working_time,
                 GUID event_id,
                 datetime event_timestamp,
                 datetime expire_time=None):
        """
        Initializes a new instance of the OrderWorking class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param broker_order_id: The events broker order identifier.
        :param label: The events order label.
        :param order_side: The events order side.
        :param order_type: The events order type.
        :param quantity: The events order quantity.
        :param price: The events order price.
        :param time_in_force: The events order time in force.
        :param working_time: The events order working time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        :param expire_time: The events order expire time (optional can be None).
        """
        Precondition.type_or_none(expire_time, datetime, 'expire_time')
        Precondition.positive(quantity, 'quantity')

        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.broker_order_id = broker_order_id
        self.label = label
        self.order_side = order_side
        self.order_type = order_type
        self.quantity = quantity
        self.price = price
        self.time_in_force = time_in_force
        self.working_time = working_time
        self.expire_time = expire_time


cdef class OrderCancelled(OrderEvent):
    """
    Represents an event where an order has been cancelled with the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 datetime cancelled_time,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderCancelled class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param cancelled_time: The events order cancelled time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.cancelled_time = cancelled_time


cdef class OrderCancelReject(OrderEvent):
    """
    Represents an event where an order cancel request has been rejected by the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 datetime cancel_reject_time,
                 str cancel_response,
                 str cancel_reject_reason,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderCancelReject class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param cancel_reject_time: The events order cancel reject time.
        :param cancel_response: The events order cancel reject response.
        :param cancel_reject_reason: The events order cancel reject reason.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        Precondition.valid_string(cancel_response, 'cancel_response')
        Precondition.valid_string(cancel_reject_reason, 'cancel_reject_reason')

        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.cancel_reject_time = cancel_reject_time
        self.cancel_reject_response = cancel_response
        self.cancel_reject_reason = cancel_reject_reason

    def __str__(self) -> str:
        """
        :return: The str() string representation of the event.
        """
        return (f"{self.__class__.__name__}"
                f"(id={self.order_id}, reason={self.cancel_reject_reason})")


cdef class OrderExpired(OrderEvent):
    """
    Represents an event where an order has expired with the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 datetime expired_time,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderExpired class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param expired_time: The events order expired time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.expired_time = expired_time


cdef class OrderModified(OrderEvent):
    """
    Represents an event where an order has been modified with the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 OrderId broker_order_id,
                 Decimal modified_price,
                 datetime modified_time,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderModified class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param broker_order_id: The events order broker identifier.
        :param modified_price: The events modified price.
        :param modified_time: The events modified time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.broker_order_id = broker_order_id
        self.modified_price = modified_price
        self.modified_time = modified_time


cdef class OrderFilled(OrderEvent):
    """
    Represents an event where an order has been completely filled with the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 ExecutionId execution_id,
                 ExecutionTicket execution_ticket,
                 OrderSide order_side,
                 int filled_quantity,
                 Decimal average_price,
                 datetime execution_time,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderFilled class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param execution_id: The events order execution identifier.
        :param execution_ticket: The events order execution ticket.
        :param order_side: The events execution order side.
        :param filled_quantity: The events execution filled quantity.
        :param average_price: The events execution average price.
        :param execution_time: The events execution time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        Precondition.positive(filled_quantity, 'filled_quantity')

        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.execution_id = execution_id
        self.execution_ticket = execution_ticket
        self.order_side = order_side
        self.filled_quantity = filled_quantity
        self.average_price = average_price
        self.execution_time = execution_time


cdef class OrderPartiallyFilled(OrderEvent):
    """
    Represents an event where an order has been partially filled with the broker.
    """

    def __init__(self,
                 Symbol symbol,
                 OrderId order_id,
                 ExecutionId execution_id,
                 ExecutionTicket execution_ticket,
                 OrderSide order_side,
                 int filled_quantity,
                 int leaves_quantity,
                 Decimal average_price,
                 execution_time: datetime,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the OrderPartiallyFilled class.

        :param symbol: The events order symbol.
        :param order_id: The events order identifier.
        :param execution_id: The events order execution identifier.
        :param execution_ticket: The events order execution ticket.
        :param order_side: The events execution order side.
        :param filled_quantity: The events execution filled quantity.
        :param leaves_quantity: The events leaves quantity.
        :param average_price: The events execution average price.
        :param execution_time: The events execution time.
        :param event_id: The events identifier.
        :param event_timestamp: The events timestamp.
        """
        Precondition.positive(filled_quantity, 'filled_quantity')
        Precondition.positive(leaves_quantity, 'leaves_quantity')

        super().__init__(symbol,
                         order_id,
                         event_id,
                         event_timestamp)
        self.execution_id = execution_id
        self.execution_ticket = execution_ticket
        self.order_side = order_side
        self.filled_quantity = filled_quantity
        self.leaves_quantity = leaves_quantity
        self.average_price = average_price
        self.execution_time = execution_time


cdef class TimeEvent(Event):
    """
    Represents a time event occurring at the event timestamp.
    """

    def __init__(self,
                 Label label,
                 GUID event_id,
                 datetime event_timestamp):
        """
        Initializes a new instance of the TimeEvent class.

        :param event_id: The time events identifier.
        :param event_timestamp: The time events timestamp.
        """
        super().__init__(event_id, event_timestamp)
        self.label = label

    def __str__(self) -> str:
        """
        :return: The str() string representation of the event.
        """
        return f"{self.__class__.__name__}(label={self.label}, timestamp={self.timestamp})"

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the event.
        """
        return f"<{str(self)} object at {id(self)}>"