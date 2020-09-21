# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2020 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from cpython.datetime cimport datetime

from nautilus_trader.common.clock cimport Clock
from nautilus_trader.core.correctness cimport Condition


cdef class IdentifierGenerator:
    """
    Provides a generator for unique identifier strings.
    """

    def __init__(self,
                 str prefix not None,
                 IdTag id_tag_trader not None,
                 IdTag id_tag_strategy not None,
                 Clock clock not None,
                 int initial_count=0):
        """
        Initialize a new instance of the IdentifierGenerator class.

        Parameters
        ----------
        prefix : str
            The prefix for each generated identifier.
        id_tag_trader : IdTag
            The identifier tag for the trader.
        id_tag_strategy : IdTag
            The identifier tag for the strategy.
        clock : Clock
            The internal clock.
        initial_count : int
            The initial count for the generator.

        Raises
        ------
        ValueError
            If prefix is not a valid string.
        ValueError
            If initial_count is negative (< 0).

        """
        Condition.valid_string(prefix, "prefix")
        Condition.not_negative_int(initial_count, "initial_count")

        self._clock = clock
        self.prefix = prefix
        self.id_tag_trader = id_tag_trader
        self.id_tag_strategy = id_tag_strategy
        self.count = initial_count

    cpdef void set_count(self, int count) except *:
        """
        Set the internal counter to the given count.

        Parameters
        ----------
        count : int
            The count to set.

        """
        self.count = count

    cpdef void reset(self) except *:
        """
        Reset the identifier generator by setting all stateful values to their
        default value.
        """
        self.count = 0

    cdef str _generate(self):
        """
        Return a unique identifier string.

        Returns
        -------
        str

        """
        self.count += 1

        return (f"{self.prefix}-"
                f"{self._get_datetime_tag()}-"
                f"{self.id_tag_trader.value}-"
                f"{self.id_tag_strategy.value}-"
                f"{self.count}")

    cdef str _get_datetime_tag(self):
        """
        Return the datetime tag string for the current time.

        Returns
        -------
        str

        """
        cdef datetime utc_now = self._clock.utc_now()
        return (f"{utc_now.year}"
                f"{utc_now.month:02d}"
                f"{utc_now.day:02d}"
                f"-"
                f"{utc_now.hour:02d}"
                f"{utc_now.minute:02d}"
                f"{utc_now.second:02d}")


cdef class OrderIdGenerator(IdentifierGenerator):
    """
    Provides a generator for unique OrderId(s).
    """

    def __init__(self,
                 IdTag id_tag_trader not None,
                 IdTag id_tag_strategy not None,
                 Clock clock not None,
                 int initial_count=0):
        """
        Initialize a new instance of the OrderIdGenerator class.

        Parameters
        ----------
        id_tag_trader : IdTag
            The order identifier tag for the trader.
        id_tag_strategy : IdTag
            The order identifier tag for the strategy.
        clock : Clock
            The clock for the component.
        initial_count : int
            The initial count for the generator.

        Raises
        ------
        ValueError
            If initial_count is negative (< 0).

        """
        super().__init__("O",
                         id_tag_trader,
                         id_tag_strategy,
                         clock,
                         initial_count)

    cpdef OrderId generate(self):
        """
        Return a unique order identifier.

        Returns
        -------
        OrderId

        """
        return OrderId(self._generate())


cdef class PositionIdGenerator(IdentifierGenerator):
    """
    Provides a generator for unique PositionId(s).
    """

    def __init__(self,
                 IdTag id_tag_trader not None,
                 IdTag id_tag_strategy not None,
                 Clock clock not None,
                 int initial_count=0):
        """
        Initialize a new instance of the PositionIdGenerator class.

        Parameters
        ----------
        id_tag_trader : IdTag
            The position identifier tag for the trader.
        id_tag_strategy : IdTag
            The position identifier tag for the strategy.
        clock : Clock
            The clock for the component.
        initial_count : int
            The initial count for the generator.

        Raises
        ------
        ValueError
            If initial_count is negative (< 0).

        """
        super().__init__("P",
                         id_tag_trader,
                         id_tag_strategy,
                         clock,
                         initial_count)

    cpdef PositionId generate(self):
        """
        Return a unique position identifier.

        Returns
        -------
        PositionId

        """
        return PositionId(self._generate())
