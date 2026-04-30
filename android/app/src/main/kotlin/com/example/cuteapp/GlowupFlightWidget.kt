package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupFlightWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)

            val views = RemoteViews(context.packageName, R.layout.glowup_flight_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read flight data saved by Flutter
            val hasData = widgetData.getBoolean("flight_has_data", false)
            val route = widgetData.getString("flight_route", null)
            val flightNumber = widgetData.getString("flight_number", null)
            val countdown = widgetData.getString("flight_countdown", null)

            if (hasData && route != null) {
                views.setTextViewText(R.id.flight_route, route)
                views.setTextViewText(R.id.flight_countdown, countdown ?: "—")

                if (flightNumber != null) {
                    views.setTextViewText(R.id.flight_number, flightNumber)
                    views.setViewVisibility(R.id.flight_number, android.view.View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.flight_number, android.view.View.GONE)
                }
            } else {
                views.setTextViewText(R.id.flight_route, "No upcoming flights ✈️")
                views.setTextViewText(R.id.flight_countdown, "—")
                views.setViewVisibility(R.id.flight_number, android.view.View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
