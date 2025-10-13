from django.views.generic import View
from django.http import HttpResponse, JsonResponse
from .models import Event
from django.shortcuts import redirect, reverse
import pandas as pd

from django.utils import timezone
import json


class PandasExport(View):
    display_name = 'Events export'
    url_name = 'export_decisions'
    url_pattern = fr'events/export'
    content_type = 'text/csv'

    def get(self, request, *args, **kwargs):
        events = Event.objects.all().values(
            'owner__participant__code',
            'owner__session__code',
            'owner__round_number',
            'name',
            'balance',
            'tick_number',
            'n_transactions',
            'timestamp',
            'body',
            'owner__gamified',
            'owner__training',
            'owner__subsession__tick_frequency',

        )
        df = pd.DataFrame(data=events)

        df['secs_since_round_starts'] = df['body'].apply(lambda x: json.loads(x).get('secs_since_round_starts'))
        if df is not None and not df.empty:
            timestamp = timezone.now()
            curtime = timestamp.strftime('%m_%d_%Y_%H_%M_%S')
            csv_data = df.to_csv(index=False)
            response = HttpResponse(csv_data, content_type=self.content_type)
            filename = f'events_{curtime}.csv'
            response['Content-Disposition'] = f'attachment; filename={filename}'
            return response
        else:
            return redirect(reverse('ExportIndex'))
