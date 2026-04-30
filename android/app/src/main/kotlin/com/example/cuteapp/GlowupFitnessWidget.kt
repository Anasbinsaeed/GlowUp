package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupFitnessWidget : AppWidgetProvider() {

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

            val views = RemoteViews(context.packageName, R.layout.glowup_fitness_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read fitness data saved by Flutter
            val walkKm = widgetData.getString("fitness_walk_km", "0.0")
            val activities = widgetData.getInt("fitness_activities", 0)

            views.setTextViewText(R.id.fitness_walk_km, "$walkKm km walked today")
            views.setTextViewText(R.id.fitness_activities, "$activities activit${if (activities == 1) "y" else "ies"}")

            val activitiesText = if (activities == 0) {
                "No activities logged yet"
            } else {
                "$activities activit${if (activities == 1) "y" else "ies"} logged"
            }
            views.setTextViewText(R.id.fitness_activities_text, activitiesText)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
