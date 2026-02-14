FROM ubuntu

COPY build/bin /app/astrum-dominatus-backend/

# Database server port
EXPOSE 35000/tcp

CMD [ "/app/astrum-dominatus-backend/AstrumDominatus.x86_64", "--headless"]
