package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupGroceryWidget : AppWidgetProvider() {

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

            val views = RemoteViews(context.packageName, R.layout.glowup_grocery_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read grocery data saved by Flutter
            val count = widgetData.getInt("grocery_count", 0)
            val item1 = widgetData.getString("grocery_1", null)
            val item2 = widgetData.getString("grocery_2", null)

            views.setTextViewText(R.id.grocery_count, "$count item${if (count == 1) "" else "s"} left")

            if (item1 != null) {
                views.setTextViewText(R.id.grocery_1, item1)
            } else {
                views.setTextViewText(R.id.grocery_1, "List is empty 🎉")
            }

            if (item2 != null) {
                views.setTextViewText(R.id.grocery_2, item2)
                views.setViewVisibility(R.id.grocery_2, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.grocery_2, android.view.View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
