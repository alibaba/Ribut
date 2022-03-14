package com.youku.ribut.network;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.youku.ribut.demo.R;

public class NetworkAdapter extends RecyclerView.Adapter<NetworkAdapter.ViewHolder> {
    private Context context;
    private NetworkDataBean dataBean;

    public NetworkAdapter(Context context, NetworkDataBean dataBean) {
        this.context = context;
        this.dataBean = dataBean;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_network, null);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        if (null != dataBean
                && dataBean.getData() != null
                && dataBean.getData().getForecast() != null) {
            NetworkDataBean.DataDTO.ForecastDTO forecast = dataBean.getData().getForecast().get(position);
            holder.date.setText(forecast.getYmd());
            holder.week.setText(forecast.getWeek());
            holder.wind.setText(forecast.getFl());
            holder.windDirection.setText(forecast.getFx());
            holder.weather.setText(forecast.getType());
            holder.highestTemperature.setText(forecast.getHigh());
            holder.lowestTemperature.setText(forecast.getLow());
            holder.notice.setText(forecast.getNotice());
        }
    }

    @Override
    public int getItemCount() {
        if (null != dataBean
                && dataBean.getData() != null
                && dataBean.getData().getForecast() != null) {
            return dataBean.getData().getForecast().size();
        }
        return 0;
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        TextView date;
        TextView week;
        TextView weather;
        TextView highestTemperature;
        TextView lowestTemperature;
        TextView windDirection;
        TextView wind;
        TextView notice;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            date = itemView.findViewById(R.id.date);
            week = itemView.findViewById(R.id.week);
            weather = itemView.findViewById(R.id.weather);
            highestTemperature = itemView.findViewById(R.id.highest_temperature);
            lowestTemperature = itemView.findViewById(R.id.lowest_temperature);
            windDirection = itemView.findViewById(R.id.wind_direction);
            wind = itemView.findViewById(R.id.wind);
            notice = itemView.findViewById(R.id.notice);
        }
    }
}
