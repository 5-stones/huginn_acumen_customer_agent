# frozen_string_literal: true

module Agents
    class StateCodeAgent < Agent
        include Carmen

        default_schedule '12h'

        can_dry_run!
        default_schedule 'never'

        description <<-MD
        This is a lightweight agent for deriving the abbreviation for a state/province
        given a country name and a region name. The logic of this agent is backed by Carmen

        ## Agent Options
        The following outlines the available options in this agent

        * `output_mode`  - not required ('clean' or 'merge', defaults to 'clean')
        * `country` - The name of the country
        * `region` - The name of the region


        ## Event Status

        ### 200 (Success)

        `status: 200` indicates a true success. In this case, Carmen was able to
        return a valid abbreviation with the data provided:

        ```
        {
          status: 200,
          derived_state_code: 'IL',
          { ... }
        }
        ```

        ### 404 (Not Found)

        `status: 404` indicates a potential failure. In this case, Carmen was
        unable to find an abreviation given the data provided.

        In this scenario, the agent will return the original `region` value as the
        `derived_state_code` for convenience. It is up to the end user to decide
        if this result should be handled as an error:

        ```
        {
          status: 404,
          derived_state_code: 'Illinois';
          { ... }
        }
        ```

        ### 500 (Error)

        `status: 500` indicates a true error. In this case, something has gone
        wrong in the agent's process and we were unable to return a useful result:

        ```
        {
          status: 500,
          message: 'Failed to derive a state code with the data provided',
          data: { country: 'United States', region: 'Illinois' },
        }
        ```

        MD

        def default_options
            {
                'country' => '',
                'region' => '',
                'output_mode' => 'clean',
            }
        end

        def validate_options
            unless options['country'].present?
                errors.add(:base, 'country is a required field')
            end

            unless options['region'].present?
                errors.add(:base, 'region is a required field')
            end

            if options['output_mode'].present? && !options['output_mode'].to_s.include?('{') && !%[clean merge].include?(options['output_mode'].to_s)
              errors.add(:base, "if provided, output_mode must be 'clean' or 'merge'")
            end

        end

        def working?
            received_event_without_error?
        end

        def check
            handle interpolated(event.payload)['payload'].presence || {}
        end

        def receive(incoming_events)
            incoming_events.each do |event|
                handle(event)
            end
       end

        private

        def handle(event)
          log('------------------------------')
              log(interpolated(event.payload))
          log('------------------------------')
            # Process agent options
            new_event = interpolated(event.payload)['output_mode'].to_s == 'merge' ? event.payload : {}

            begin
                country = Country.named(interpolated(event.payload)['country'])
                region = country.nil? ? nil : country.subregions.named(interpolated(event.payload)['region'])

                status = region.nil? ? 404 : 200
                state_code = region.nil? ? interpolated(event.payload)['region'] : region.code

                create_event payload: new_event.merge(
                  status: status,
                  derived_state_code: state_code,
                )

            rescue e
              create_event payload: new_event.merge(
                status: 500,
                message: e.message,
                data: { country: country, region: interpolated(event.payload)['region'] },
              )
            end
        end

    end
end
